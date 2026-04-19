# Unit Test Plan: V-Model Extension Pack MVP

**Feature Branch**: `001-v-model-mvp`
**Created**: 2026-04-19
**Status**: Draft
**Source**: `specs/001-v-model-mvp/v-model/module-design.md`

## Overview

This document specifies white-box unit test cases for all twenty-eight modules defined in `module-design.md`. Each module receives at least one UTP from Statement & Branch Coverage, with additional techniques (BVA, Equivalence Partitioning, Strict Isolation, State Transition Testing) applied where module characteristics warrant. All scenarios use Arrange/Act/Assert format. No safety-critical techniques (MC/DC, Fault Injection) apply — no domain is configured in `v-model-config.yml`.

**External Modules**: 0 (no `[EXTERNAL]` tags in module-design.md)

## ID Schema

- **Unit Test Procedure**: `UTP-NNN-X` — NNN = parent MOD number, X = letter suffix (A, B, C…)
- **Unit Test Scenario**: `UTS-NNN-X#` — # = scenario number under the parent UTP
- Example: `UTS-008-B2` = second scenario of the Equivalence Partitioning test for MOD-008

## Technique Distribution

| Technique | UTP Count | Applicable Modules |
|-----------|-----------|-------------------|
| Statement & Branch Coverage | 28 | All 28 MODs |
| Boundary Value Analysis | 6 | MOD-003, MOD-005, MOD-010, MOD-014, MOD-019, MOD-025 |
| Equivalence Partitioning | 8 | MOD-001, MOD-002, MOD-008, MOD-017, MOD-020, MOD-023, MOD-026, MOD-028 |
| Strict Isolation | 14 | MOD-003, MOD-006, MOD-009, MOD-013, MOD-015, MOD-016, MOD-018, MOD-019, MOD-020, MOD-021, MOD-022, MOD-023, MOD-026, MOD-028 |
| State Transition Testing | 1 | MOD-024 |
| **Total** | **57** | |

## Unit Test Specifications

---

### MOD-001: parse_spec_content

#### UTP-001-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise all branches in `parse_spec_content` — empty input guard, each section header match, supplementary text path, and malformed Markdown degradation.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-001-A1 — Both inputs empty raises EMPTY_INPUT**

- **Arrange**: `spec_content = ""`, `user_text = ""`
- **Act**: Call `parse_spec_content(spec_content, user_text)`
- **Assert**: Raises `EMPTY_INPUT` with message containing "Both spec_content and user_text are empty"

**UTS-001-A2 — Spec with all four section types**

- **Arrange**: `spec_content` = Markdown with `## User Stories` (2 items), `## Functional Requirements` (1 row), `## Quality Attributes` (1 row), `## Constraints` (1 row). `user_text = ""`
- **Act**: Call `parse_spec_content(spec_content, "")`
- **Assert**: `result.user_stories` has length 2; `result.functional_reqs` has length 1; `result.quality_attrs` has length 1; `result.constraints` has length 1

**UTS-001-A3 — Spec content with supplementary text**

- **Arrange**: `spec_content` = Markdown with `## User Stories` (1 item). `user_text = "The system shall log all events."`
- **Act**: Call `parse_spec_content(spec_content, user_text)`
- **Assert**: `result.user_stories` has length 1; `result.functional_reqs` has length ≥ 1 (supplementary text extracted)

**UTS-001-A4 — Malformed Markdown with no h2 headers**

- **Arrange**: `spec_content = "No headers here, just text."`, `user_text = ""`
- **Act**: Call `parse_spec_content(spec_content, "")`
- **Assert**: Returns `ParsedRepr` with all four arrays empty (graceful degradation, no exception). Note: `EMPTY_INPUT` not raised because `spec_content` is not empty.

#### UTP-001-B — Equivalence Partitioning

**Technique**: Equivalence Partitioning
**Objective**: Verify each section header category is correctly recognized as a distinct equivalence class.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-001-B1 — "User Stories" partition**

- **Arrange**: `spec_content` = Markdown with only `## User Stories` section containing 3 numbered items
- **Act**: Call `parse_spec_content(spec_content, "")`
- **Assert**: Only `user_stories` populated (length 3); `functional_reqs`, `quality_attrs`, `constraints` all empty

**UTS-001-B2 — "Functional Requirements" partition**

- **Arrange**: `spec_content` = Markdown with only `## Functional Requirements` table (2 rows)
- **Act**: Call `parse_spec_content(spec_content, "")`
- **Assert**: Only `functional_reqs` populated (length 2); all others empty

**UTS-001-B3 — "Quality Attributes" partition**

- **Arrange**: `spec_content` = Markdown with only `## Quality Attributes` table (1 row)
- **Act**: Call `parse_spec_content(spec_content, "")`
- **Assert**: Only `quality_attrs` populated (length 1); all others empty

**UTS-001-B4 — Unrecognized header (invalid partition)**

- **Arrange**: `spec_content` = Markdown with `## Appendix` section only
- **Act**: Call `parse_spec_content(spec_content, "")`
- **Assert**: All four arrays empty (section ignored)

---

### MOD-002: synthesize_requirements

#### UTP-002-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise all loops and overlay branch in `synthesize_requirements`.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module receives parsed data as parameters |

**UTS-002-A1 — Empty parsed_repr raises SYNTHESIS_FAILURE**

- **Arrange**: `parsed_repr` with all four arrays empty. `overlay_content = ""`, `template_structure = "{}"`
- **Act**: Call `synthesize_requirements(parsed_repr, "", "{}")`
- **Assert**: Raises `SYNTHESIS_FAILURE`

**UTS-002-A2 — Happy path with stories, FRs, QAs, and constraints**

- **Arrange**: `parsed_repr` with 1 user story, 1 functional req, 1 quality attribute, 1 constraint (type="general"). `overlay_content = ""`
- **Act**: Call `synthesize_requirements(parsed_repr, "", template)`
- **Assert**: Returns 4 requirements — IDs `REQ-001` (Functional from story), `REQ-002` (Functional from FR), `REQ-NF-001` (Non-Functional from QA), `REQ-CN-001` (Constraint)

**UTS-002-A3 — Overlay content enrichment branch**

- **Arrange**: `parsed_repr` with 1 functional req. `overlay_content = "## Safety\nASIL-B allocation required"`
- **Act**: Call `synthesize_requirements(parsed_repr, overlay_content, template)`
- **Assert**: Returned requirement has domain guidance applied (overlay content referenced in output)

**UTS-002-A4 — Constraint with interface type**

- **Arrange**: `parsed_repr` with 1 constraint where `type = "interface"`
- **Act**: Call `synthesize_requirements(parsed_repr, "", template)`
- **Assert**: Returned requirement has `id = "REQ-IF-001"` and `category = "Interface"`

#### UTP-002-B — Equivalence Partitioning

**Technique**: Equivalence Partitioning
**Objective**: Verify each requirement category partition receives correct ID prefix.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-002-B1 — Functional category partition → REQ-NNN**

- **Arrange**: `parsed_repr` with only `functional_reqs` (2 items)
- **Act**: Call `synthesize_requirements(parsed_repr, "", template)`
- **Assert**: IDs are `REQ-001`, `REQ-002`; all have `category = "Functional"`

**UTS-002-B2 — Non-Functional category partition → REQ-NF-NNN**

- **Arrange**: `parsed_repr` with only `quality_attrs` (1 item)
- **Act**: Call `synthesize_requirements(parsed_repr, "", template)`
- **Assert**: ID is `REQ-NF-001`; `category = "Non-Functional"`

**UTS-002-B3 — Interface category partition → REQ-IF-NNN**

- **Arrange**: `parsed_repr` with only `constraints` (1 item, `type = "interface"`)
- **Act**: Call `synthesize_requirements(parsed_repr, "", template)`
- **Assert**: ID is `REQ-IF-001`; `category = "Interface"`

---

### MOD-003: validate_requirement_quality

#### UTP-003-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise all 8 quality criterion branches, banned-term delegation, and the 50% rejection threshold.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| MOD-004 (check_banned_terms) | Internal function call | Stub returning `[]` for clean reqs, `["fast"]` for banned reqs |

**UTS-003-A1 — All 8 criteria pass**

- **Arrange**: `draft_requirements` = 1 requirement with description "The system shall respond within 200ms" (atomic, testable, unambiguous, complete, consistent, traceable, feasible, necessary). Stub MOD-004 → `[]`
- **Act**: Call `validate_requirement_quality(draft_requirements)`
- **Assert**: `validated` has length 1; `rejected` is empty

**UTS-003-A2 — Banned term triggers rejection**

- **Arrange**: `draft_requirements` = 1 requirement with description "The system shall be fast". Stub MOD-004 → `["fast"]`
- **Act**: Call `validate_requirement_quality(draft_requirements)`
- **Assert**: `rejected` has length 1; rejection reason contains "banned terms: fast"

**UTS-003-A3 — Multiple criteria fail**

- **Arrange**: `draft_requirements` = 1 requirement with untestable, incomplete description. Stub MOD-004 → `[]`
- **Act**: Call `validate_requirement_quality(draft_requirements)`
- **Assert**: `rejected` has length 1; `failed_criteria` contains "testable" and "complete"

**UTS-003-A4 — 50% threshold exceeded raises VALIDATION_THRESHOLD**

- **Arrange**: `draft_requirements` = 4 requirements, 3 of which fail at least one criterion. Stub MOD-004 → `[]`
- **Act**: Call `validate_requirement_quality(draft_requirements)`
- **Assert**: Raises `VALIDATION_THRESHOLD` with message "3 of 4 requirements failed"

#### UTP-003-B — Boundary Value Analysis

**Technique**: Boundary Value Analysis
**Objective**: Test the 50% rejection threshold boundary.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| MOD-004 (check_banned_terms) | Internal function call | Stub returning `[]` |

**UTS-003-B1 — Exactly 50% fail (boundary — no exception)**

- **Arrange**: `draft_requirements` = 4 requirements, exactly 2 failing. Stub MOD-004 → `[]`
- **Act**: Call `validate_requirement_quality(draft_requirements)`
- **Assert**: No exception raised; `validated` length 2; `rejected` length 2

**UTS-003-B2 — 51% fail (just over boundary — exception)**

- **Arrange**: `draft_requirements` = 2 requirements, both failing (100% > 50%). Stub MOD-004 → `[]`
- **Act**: Call `validate_requirement_quality(draft_requirements)`
- **Assert**: Raises `VALIDATION_THRESHOLD`

**UTS-003-B3 — 0% fail (minimum)**

- **Arrange**: `draft_requirements` = 3 requirements, all passing. Stub MOD-004 → `[]`
- **Act**: Call `validate_requirement_quality(draft_requirements)`
- **Assert**: No exception; `validated` length 3; `rejected` empty

**UTS-003-B4 — 100% fail (maximum)**

- **Arrange**: `draft_requirements` = 2 requirements, both failing. Stub MOD-004 → `[]`
- **Act**: Call `validate_requirement_quality(draft_requirements)`
- **Assert**: Raises `VALIDATION_THRESHOLD` with message "2 of 2"

**UTS-003-B5 — Single requirement that fails (1/1 = 100%)**

- **Arrange**: `draft_requirements` = 1 requirement, failing. Stub MOD-004 → `[]`
- **Act**: Call `validate_requirement_quality(draft_requirements)`
- **Assert**: Raises `VALIDATION_THRESHOLD` with message "1 of 1"

#### UTP-003-C — Strict Isolation

**Technique**: Strict Isolation
**Objective**: Verify MOD-003 correctly delegates to MOD-004 and handles its return values.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| MOD-004 (check_banned_terms) | Internal function call | Controlled stub |

**UTS-003-C1 — MOD-004 returns empty → no banned-term failure**

- **Arrange**: `draft_requirements` = 1 valid requirement. Stub MOD-004 → `[]`
- **Act**: Call `validate_requirement_quality(draft_requirements)`
- **Assert**: Requirement is in `validated`; MOD-004 called once with the requirement's description

**UTS-003-C2 — MOD-004 returns multiple hits → all reported**

- **Arrange**: `draft_requirements` = 1 requirement with description "The system shall be fast and efficient". Stub MOD-004 → `["fast", "efficient"]`
- **Act**: Call `validate_requirement_quality(draft_requirements)`
- **Assert**: `rejected[0].reason` contains "banned terms: fast, efficient"

---

### MOD-004: check_banned_terms

#### UTP-004-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise the loop, regex word-boundary check, and empty-input path.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-004-A1 — Empty description**

- **Arrange**: `description = ""`
- **Act**: Call `check_banned_terms("")`
- **Assert**: Returns empty array

**UTS-004-A2 — Description with one banned term**

- **Arrange**: `description = "The system must be fast enough"`
- **Act**: Call `check_banned_terms(description)`
- **Assert**: Returns `["fast"]`

**UTS-004-A3 — Substring not matched (word boundary)**

- **Arrange**: `description = "breakfast is served at the facility"`
- **Act**: Call `check_banned_terms(description)`
- **Assert**: Returns empty array ("fast" is substring of "breakfast" but not a word boundary match)

**UTS-004-A4 — Multiple banned terms**

- **Arrange**: `description = "The system shall be robust and scalable"`
- **Act**: Call `check_banned_terms(description)`
- **Assert**: Returns `["robust", "scalable"]`

---

### MOD-005: create_requirement_batches

#### UTP-005-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise empty-input guard, batch_size < 1 fallback, loop, and last-batch handling.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-005-A1 — Empty requirements list raises EMPTY_REQUIREMENTS**

- **Arrange**: `requirements = []`, `batch_size = 5`
- **Act**: Call `create_requirement_batches([], 5)`
- **Assert**: Raises `EMPTY_REQUIREMENTS`

**UTS-005-A2 — batch_size < 1 falls back to default 5**

- **Arrange**: `requirements` = 7 items, `batch_size = 0`
- **Act**: Call `create_requirement_batches(requirements, 0)`
- **Assert**: Returns 2 batches — first with 5 items, second with 2 items

**UTS-005-A3 — Exact multiple of batch_size**

- **Arrange**: `requirements` = 10 items, `batch_size = 5`
- **Act**: Call `create_requirement_batches(requirements, 5)`
- **Assert**: Returns exactly 2 batches, each with 5 items

**UTS-005-A4 — Last batch smaller than batch_size**

- **Arrange**: `requirements` = 3 items, `batch_size = 5`
- **Act**: Call `create_requirement_batches(requirements, 5)`
- **Assert**: Returns 1 batch with 3 items

#### UTP-005-B — Boundary Value Analysis

**Technique**: Boundary Value Analysis
**Objective**: Test batch_size boundaries and edge counts.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-005-B1 — batch_size = 1 (minimum valid)**

- **Arrange**: `requirements` = 3 items, `batch_size = 1`
- **Act**: Call `create_requirement_batches(requirements, 1)`
- **Assert**: Returns 3 batches, each with 1 item

**UTS-005-B2 — batch_size equals requirement count**

- **Arrange**: `requirements` = 5 items, `batch_size = 5`
- **Act**: Call `create_requirement_batches(requirements, 5)`
- **Assert**: Returns exactly 1 batch with 5 items

**UTS-005-B3 — batch_size exceeds requirement count**

- **Arrange**: `requirements` = 2 items, `batch_size = 100`
- **Act**: Call `create_requirement_batches(requirements, 100)`
- **Assert**: Returns 1 batch with 2 items

**UTS-005-B4 — Single requirement**

- **Arrange**: `requirements` = 1 item, `batch_size = 5`
- **Act**: Call `create_requirement_batches(requirements, 5)`
- **Assert**: Returns 1 batch with 1 item

---

### MOD-006: generate_atp_scn

#### UTP-006-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise happy-path generation (A suffix), edge-case loop (B, C suffixes), and AI failure path.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| AI Runtime | External service | Stub returning valid BDD scenario strings |

**UTS-006-A1 — Single requirement produces ATP-A with SCN**

- **Arrange**: `batch` = 1 requirement (REQ-001), `start_atp_number = 1`. Stub AI → returns valid BDD scenario
- **Act**: Call `generate_atp_scn(batch, 1, "")`
- **Assert**: Returns entries with ATP-001-A; ATP-001-A has ≥ 1 scenario (SCN-001-A1)

**UTS-006-A2 — Requirement with edge cases produces B, C suffixes**

- **Arrange**: `batch` = 1 requirement with boundary conditions (e.g., "shall handle 1–100 items"). Stub AI → returns 2 edge cases
- **Act**: Call `generate_atp_scn(batch, 1, "")`
- **Assert**: Returns ATP-001-A, ATP-001-B, ATP-001-C entries

**UTS-006-A3 — Multiple requirements increment ATP numbers**

- **Arrange**: `batch` = 2 requirements (REQ-001, REQ-002), `start_atp_number = 5`. Stub AI → returns valid output
- **Act**: Call `generate_atp_scn(batch, 5, "")`
- **Assert**: First req gets ATP-005-A, second gets ATP-006-A; `next_atp_number = 7`

#### UTP-006-B — Strict Isolation

**Technique**: Strict Isolation
**Objective**: Verify AI runtime isolation — correct behavior on success and failure.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| AI Runtime | External service | Controlled stub |

**UTS-006-B1 — AI runtime returns valid BDD → entries produced**

- **Arrange**: Stub AI runtime → returns well-formed BDD scenario. `batch` = 1 requirement
- **Act**: Call `generate_atp_scn(batch, 1, "")`
- **Assert**: Entries non-empty; AI runtime invoked exactly once per requirement

**UTS-006-B2 — AI runtime failure raises GENERATION_FAILURE**

- **Arrange**: Stub AI runtime → raises error on both attempts (initial + retry)
- **Act**: Call `generate_atp_scn(batch, 1, "")`
- **Assert**: Raises `GENERATION_FAILURE` after retry

---

### MOD-007: assemble_acceptance_plan

#### UTP-007-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise merge, dedup check, coverage gap detection, and summary computation.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module receives batch data as parameters |

**UTS-007-A1 — Two batches merged, full coverage**

- **Arrange**: `batch_outputs` = 2 batches with entries covering REQ-001, REQ-002. `requirements` = [REQ-001, REQ-002]
- **Act**: Call `assemble_acceptance_plan(batch_outputs, requirements)`
- **Assert**: `coverage_pct = 100`; `total_atps` = sum of batch entries

**UTS-007-A2 — Duplicate ATP ID across batches raises ID_CONFLICT**

- **Arrange**: `batch_outputs` = 2 batches both containing `ATP-001-A`
- **Act**: Call `assemble_acceptance_plan(batch_outputs, requirements)`
- **Assert**: Raises `ID_CONFLICT` with message containing "ATP-001-A"

**UTS-007-A3 — Coverage gap detected raises COVERAGE_GAP**

- **Arrange**: `batch_outputs` covers only REQ-001. `requirements` = [REQ-001, REQ-002]
- **Act**: Call `assemble_acceptance_plan(batch_outputs, requirements)`
- **Assert**: Raises `COVERAGE_GAP` with message containing "REQ-002"

**UTS-007-A4 — SCN count computed correctly**

- **Arrange**: `batch_outputs` = 1 batch with 2 ATP entries, each having 3 scenarios
- **Act**: Call `assemble_acceptance_plan(batch_outputs, requirements)`
- **Assert**: `total_scns = 6`

---

### MOD-008: extract_ids

#### UTP-008-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise all three `id_type` switch branches, deduplication, and empty-match path.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained (regex on input string) |

**UTS-008-A1 — Extract REQ IDs with standard prefixes**

- **Arrange**: `markdown_content = "REQ-001 maps to REQ-NF-002 and REQ-IF-001"`, `id_type = "REQ"`
- **Act**: Call `extract_ids(markdown_content, "REQ")`
- **Assert**: Returns `["REQ-001", "REQ-IF-001", "REQ-NF-002"]` (sorted, deduplicated)

**UTS-008-A2 — Extract ATP IDs**

- **Arrange**: `markdown_content = "ATP-001-A, ATP-001-B, ATP-002-A"`, `id_type = "ATP"`
- **Act**: Call `extract_ids(markdown_content, "ATP")`
- **Assert**: Returns `["ATP-001-A", "ATP-001-B", "ATP-002-A"]`

**UTS-008-A3 — No matches found**

- **Arrange**: `markdown_content = "No identifiers here"`, `id_type = "REQ"`
- **Act**: Call `extract_ids(markdown_content, "REQ")`
- **Assert**: Returns empty array

**UTS-008-A4 — Duplicates deduplicated**

- **Arrange**: `markdown_content = "REQ-001 appears in REQ-001 and REQ-001"`, `id_type = "REQ"`
- **Act**: Call `extract_ids(markdown_content, "REQ")`
- **Assert**: Returns `["REQ-001"]` (single entry)

#### UTP-008-B — Equivalence Partitioning

**Technique**: Equivalence Partitioning
**Objective**: Verify each `id_type` enum value selects the correct regex pattern.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-008-B1 — "REQ" partition matches REQ/REQ-NF/REQ-IF/REQ-CN patterns**

- **Arrange**: `markdown_content` containing `REQ-001`, `REQ-NF-001`, `REQ-IF-001`, `REQ-CN-001`, `ATP-001-A`. `id_type = "REQ"`
- **Act**: Call `extract_ids(markdown_content, "REQ")`
- **Assert**: Returns 4 REQ IDs; does not include `ATP-001-A`

**UTS-008-B2 — "ATP" partition matches only ATP pattern**

- **Arrange**: `markdown_content` containing `ATP-001-A`, `REQ-001`, `SCN-001-A1`. `id_type = "ATP"`
- **Act**: Call `extract_ids(markdown_content, "ATP")`
- **Assert**: Returns `["ATP-001-A"]` only

**UTS-008-B3 — "SCN" partition matches SCN pattern with numeric suffix**

- **Arrange**: `markdown_content` containing `SCN-001-A1`, `SCN-002-B3`, `ATP-001-A`. `id_type = "SCN"`
- **Act**: Call `extract_ids(markdown_content, "SCN")`
- **Assert**: Returns `["SCN-001-A1", "SCN-002-B3"]`

---

### MOD-009: build_matrix_tables

#### UTP-009-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise empty REQ guard, REQ→ATP mapping, ATP→SCN mapping, and stats delegation.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| MOD-010 (compute_coverage_stats) | Internal function call | Stub returning fixed CoverageStats |

**UTS-009-A1 — Empty REQ ID set raises EMPTY_ID_SET**

- **Arrange**: `req_ids = []`, `atp_ids = ["ATP-001-A"]`. Stub MOD-010 not called
- **Act**: Call `build_matrix_tables([], ["ATP-001-A"], [], "")`
- **Assert**: Raises `EMPTY_ID_SET`

**UTS-009-A2 — REQ→ATP→SCN mapping built correctly**

- **Arrange**: `req_ids = ["REQ-001"]`, `atp_ids = ["ATP-001-A"]`, `scn_ids = ["SCN-001-A1"]`. `acceptance_content` links ATP-001-A to REQ-001. Stub MOD-010 → fixed stats
- **Act**: Call `build_matrix_tables(req_ids, atp_ids, scn_ids, acceptance_content)`
- **Assert**: `rows[0]` has req="REQ-001", atps="ATP-001-A", scns="SCN-001-A1"

**UTS-009-A3 — Orphan ATP not mapped to any REQ**

- **Arrange**: `req_ids = ["REQ-001"]`, `atp_ids = ["ATP-001-A", "ATP-999-A"]`. `acceptance_content` maps only ATP-001-A. Stub MOD-010 → fixed stats
- **Act**: Call `build_matrix_tables(req_ids, atp_ids, scn_ids, acceptance_content)`
- **Assert**: Row for REQ-001 contains ATP-001-A only; orphan ATP-999-A passed to gap analysis

#### UTP-009-B — Strict Isolation

**Technique**: Strict Isolation
**Objective**: Verify delegation to MOD-010 occurs with correct parameters.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| MOD-010 (compute_coverage_stats) | Internal function call | Spy recording call arguments |

**UTS-009-B1 — MOD-010 called with correct dictionaries**

- **Arrange**: `req_ids = ["REQ-001", "REQ-002"]`. Stub MOD-010 as spy
- **Act**: Call `build_matrix_tables(req_ids, atp_ids, scn_ids, acceptance_content)`
- **Assert**: MOD-010 called once with (req_ids, atp_ids, scn_ids, req_to_atps, atp_to_scns)

**UTS-009-B2 — MOD-010 error propagates**

- **Arrange**: Stub MOD-010 → raises RuntimeError. `req_ids = ["REQ-001"]`
- **Act**: Call `build_matrix_tables(req_ids, atp_ids, scn_ids, acceptance_content)`
- **Assert**: RuntimeError propagates to caller

---

### MOD-010: compute_coverage_stats

#### UTP-010-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise count computations and percentage calculations.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-010-A1 — Full coverage**

- **Arrange**: `req_ids = ["REQ-001", "REQ-002"]`, `atp_ids = ["ATP-001-A", "ATP-002-A"]`. `req_to_atps = {"REQ-001": ["ATP-001-A"], "REQ-002": ["ATP-002-A"]}`, `atp_to_scns = {"ATP-001-A": ["SCN-001-A1"], "ATP-002-A": ["SCN-002-A1"]}`
- **Act**: Call `compute_coverage_stats(req_ids, atp_ids, scn_ids, req_to_atps, atp_to_scns)`
- **Assert**: `req_coverage_pct = 100.0`, `atp_coverage_pct = 100.0`

**UTS-010-A2 — Partial coverage**

- **Arrange**: `req_ids = ["REQ-001", "REQ-002"]`. `req_to_atps = {"REQ-001": ["ATP-001-A"], "REQ-002": []}` (REQ-002 uncovered)
- **Act**: Call `compute_coverage_stats(...)`
- **Assert**: `req_coverage_pct = 50.0`, `reqs_covered = 1`

**UTS-010-A3 — Zero REQs (division guard)**

- **Arrange**: `req_ids = []` (hypothetical — upstream guards this, but testing module in isolation)
- **Act**: Call `compute_coverage_stats([], [], [], {}, {})`
- **Assert**: `req_coverage_pct = 0`, `atp_coverage_pct = 0` (no division by zero)

#### UTP-010-B — Boundary Value Analysis

**Technique**: Boundary Value Analysis
**Objective**: Test coverage percentage boundaries.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-010-B1 — 0% coverage (no REQs covered)**

- **Arrange**: `req_ids = ["REQ-001"]`, `req_to_atps = {"REQ-001": []}`
- **Act**: Call `compute_coverage_stats(...)`
- **Assert**: `req_coverage_pct = 0.0`

**UTS-010-B2 — 100% coverage (all REQs covered)**

- **Arrange**: `req_ids = ["REQ-001"]`, `req_to_atps = {"REQ-001": ["ATP-001-A"]}`
- **Act**: Call `compute_coverage_stats(...)`
- **Assert**: `req_coverage_pct = 100.0`

**UTS-010-B3 — Single REQ covered out of many**

- **Arrange**: `req_ids` = 10 items, only first has ATPs
- **Act**: Call `compute_coverage_stats(...)`
- **Assert**: `req_coverage_pct = 10.0`

---

### MOD-011: find_gaps

#### UTP-011-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise three gap categories and the has_gaps flag.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-011-A1 — No gaps (full coverage)**

- **Arrange**: All REQs mapped to ATPs, all ATPs mapped to SCNs, no orphans
- **Act**: Call `find_gaps(req_to_atps, atp_to_scns, all_atp_ids, all_req_ids)`
- **Assert**: `has_gaps = false`; all three arrays empty

**UTS-011-A2 — Uncovered REQ detected**

- **Arrange**: `req_to_atps = {"REQ-001": [], "REQ-002": ["ATP-002-A"]}`
- **Act**: Call `find_gaps(...)`
- **Assert**: `uncovered_reqs = ["REQ-001"]`; `has_gaps = true`

**UTS-011-A3 — Orphan ATP detected**

- **Arrange**: `all_atp_ids = ["ATP-001-A", "ATP-999-A"]`. Only ATP-001-A appears in `req_to_atps` values
- **Act**: Call `find_gaps(...)`
- **Assert**: `orphan_atps = ["ATP-999-A"]`; `has_gaps = true`

**UTS-011-A4 — All three gap categories simultaneously**

- **Arrange**: 1 uncovered REQ, 1 uncovered ATP (no SCN), 1 orphan ATP
- **Act**: Call `find_gaps(...)`
- **Assert**: All three arrays non-empty; `has_gaps = true`

---

### MOD-012: format_exception_report

#### UTP-012-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise no-gaps path and each gap section formatting.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-012-A1 — No gaps produces clean message**

- **Arrange**: `gap_report` with `has_gaps = false`
- **Act**: Call `format_exception_report(gap_report)`
- **Assert**: Output contains "No exceptions — full coverage achieved."

**UTS-012-A2 — Uncovered REQs formatted**

- **Arrange**: `gap_report` with `uncovered_reqs = ["REQ-003"]`, `has_gaps = true`
- **Act**: Call `format_exception_report(gap_report)`
- **Assert**: Output contains "### Uncovered Requirements" and "REQ-003 — No ATP mapped"

**UTS-012-A3 — All three sections present**

- **Arrange**: `gap_report` with all three arrays non-empty, `has_gaps = true`
- **Act**: Call `format_exception_report(gap_report)`
- **Assert**: Output contains all three section headers: "Uncovered Requirements", "ATPs Without Scenarios", "Orphan ATPs"

---

### MOD-013: compute_bidirectional_coverage

#### UTP-013-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise file reading, ID extraction delegation, gap detection, JSON vs. text output, and exit codes.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system (read_file) | External I/O | Stub returning mock file content |
| MOD-008 (extract_ids) | Internal function call | Stub returning controlled ID arrays |
| MOD-014 (format_json_report) | Internal function call | Stub returning `"{}"` |

**UTS-013-A1 — Full coverage returns exit code 0**

- **Arrange**: Stub files with REQ-001, ATP-001-A, SCN-001-A1 content. Stub MOD-008 → matching IDs. `json_flag = false`
- **Act**: Call `compute_bidirectional_coverage("vmodel_dir", false)`
- **Assert**: Returns exit code 0

**UTS-013-A2 — Gap detected returns exit code 1**

- **Arrange**: Stub files: requirements has REQ-001, REQ-002; acceptance only has ATP-001-A. Stub MOD-008 accordingly
- **Act**: Call `compute_bidirectional_coverage("vmodel_dir", false)`
- **Assert**: Returns exit code 1

**UTS-013-A3 — JSON flag delegates to MOD-014**

- **Arrange**: Full coverage. `json_flag = true`. Stub MOD-014 → `'{"has_gaps":false}'`
- **Act**: Call `compute_bidirectional_coverage("vmodel_dir", true)`
- **Assert**: Output is JSON; MOD-014 called once

#### UTP-013-B — Strict Isolation

**Technique**: Strict Isolation
**Objective**: Verify file system and MOD-008 isolation.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system (read_file) | External I/O | Controlled stub |
| MOD-008 (extract_ids) | Internal function call | Controlled stub |

**UTS-013-B1 — Missing input file returns exit code 1 with error**

- **Arrange**: Stub `read_file("vmodel_dir/requirements.md")` → raises FileNotFoundError
- **Act**: Call `compute_bidirectional_coverage("vmodel_dir", false)`
- **Assert**: Returns exit code 1; stderr contains error message

**UTS-013-B2 — MOD-008 called exactly 3 times (REQ, ATP, SCN)**

- **Arrange**: Stub file system → valid content. Spy on MOD-008
- **Act**: Call `compute_bidirectional_coverage("vmodel_dir", false)`
- **Assert**: MOD-008 called 3 times with id_types "REQ", "ATP", "SCN"

---

### MOD-014: format_json_report

#### UTP-014-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise JSON formatting and division-by-zero guard.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-014-A1 — Standard report with gaps**

- **Arrange**: `req_ids = ["REQ-001", "REQ-002"]`, `reqs_without_atp = ["REQ-002"]`, `has_gaps = true`
- **Act**: Call `format_json_report(req_ids, atp_ids, scn_ids, reqs_without_atp, atps_without_scn, true)`
- **Assert**: JSON contains `"has_gaps": true`, `"req_coverage_pct": 50.0`

**UTS-014-A2 — No gaps report**

- **Arrange**: All arrays populated, no gaps. `has_gaps = false`
- **Act**: Call `format_json_report(...)`
- **Assert**: JSON contains `"has_gaps": false`, `"req_coverage_pct": 100.0`

**UTS-014-A3 — Zero REQ IDs (division guard)**

- **Arrange**: `req_ids = []`, `atp_ids = []`
- **Act**: Call `format_json_report([], [], [], [], [], false)`
- **Assert**: JSON contains `"req_coverage_pct": 0`, `"atp_coverage_pct": 0` (no crash)

#### UTP-014-B — Boundary Value Analysis

**Technique**: Boundary Value Analysis
**Objective**: Test coverage percentage edge values.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-014-B1 — 0% REQ coverage**

- **Arrange**: `req_ids = ["REQ-001"]`, `reqs_without_atp = ["REQ-001"]`
- **Act**: Call `format_json_report(...)`
- **Assert**: `"req_coverage_pct": 0.0`

**UTS-014-B2 — 100% REQ coverage**

- **Arrange**: `req_ids = ["REQ-001"]`, `reqs_without_atp = []`
- **Act**: Call `format_json_report(...)`
- **Assert**: `"req_coverage_pct": 100.0`

**UTS-014-B3 — Large count (boundary of 3-digit IDs)**

- **Arrange**: `req_ids` = 999 items, all covered
- **Act**: Call `format_json_report(...)`
- **Assert**: `"total_reqs": 999`, `"req_coverage_pct": 100.0`

---

### MOD-015: parse_unified_diff

#### UTP-015-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise no-history guard, diff parsing with +/- lines, and header-line filtering.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| Git CLI (run) | External process | Stub returning controlled output strings |

**UTS-015-A1 — No Git history raises NO_GIT_HISTORY**

- **Arrange**: Stub `run("git log ...")` → returns empty string
- **Act**: Call `parse_unified_diff("vmodel_dir")`
- **Assert**: Raises `NO_GIT_HISTORY`

**UTS-015-A2 — Diff with added and removed lines**

- **Arrange**: Stub `run("git log ...")` → "abc123 initial". Stub `run("git diff ...")` → `"+REQ-005 new\n-REQ-003 old\n+REQ-003 updated"`
- **Act**: Call `parse_unified_diff("vmodel_dir")`
- **Assert**: `added_lines` contains "REQ-005 new" and "REQ-003 updated"; `removed_lines` contains "REQ-003 old"

**UTS-015-A3 — Header lines (+++ and ---) excluded**

- **Arrange**: Stub diff output containing `"--- a/requirements.md\n+++ b/requirements.md\n+REQ-001"`
- **Act**: Call `parse_unified_diff("vmodel_dir")`
- **Assert**: `added_lines = ["REQ-001"]` (headers filtered); `removed_lines` empty

#### UTP-015-B — Strict Isolation

**Technique**: Strict Isolation
**Objective**: Verify Git CLI isolation.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| Git CLI (run) | External process | Controlled stub |

**UTS-015-B1 — Git commands called with correct paths**

- **Arrange**: Stub as spy. `vmodel_dir = "specs/001/v-model"`
- **Act**: Call `parse_unified_diff("specs/001/v-model")`
- **Assert**: `run` called with paths containing `"specs/001/v-model/requirements.md"`

**UTS-015-B2 — Git not available raises NOT_GIT_REPO**

- **Arrange**: Stub `run("git log ...")` → raises "not a git repository"
- **Act**: Call `parse_unified_diff("vmodel_dir")`
- **Assert**: Raises `NOT_GIT_REPO`

---

### MOD-016: classify_changes

#### UTP-016-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise added, modified, and removed set operations.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| MOD-008 (extract_ids) | Internal function call | Stub returning controlled arrays |

**UTS-016-A1 — New IDs in added only**

- **Arrange**: `diff_result.added_lines` = "REQ-005 new". `diff_result.removed_lines` = "". Stub MOD-008 → added: `["REQ-005"]`, removed: `[]`
- **Act**: Call `classify_changes(diff_result)`
- **Assert**: `added = ["REQ-005"]`; `modified` empty; `removed` empty

**UTS-016-A2 — Modified IDs in both added and removed**

- **Arrange**: Stub MOD-008 → added: `["REQ-003"]`, removed: `["REQ-003"]`
- **Act**: Call `classify_changes(diff_result)`
- **Assert**: `modified = ["REQ-003"]`; `added` empty; `removed` empty

**UTS-016-A3 — Removed IDs in removed only**

- **Arrange**: Stub MOD-008 → added: `[]`, removed: `["REQ-002"]`
- **Act**: Call `classify_changes(diff_result)`
- **Assert**: `removed = ["REQ-002"]`; `added` empty; `modified` empty

**UTS-016-A4 — No changes (empty diff)**

- **Arrange**: Stub MOD-008 → added: `[]`, removed: `[]`
- **Act**: Call `classify_changes(diff_result)`
- **Assert**: All three arrays empty

#### UTP-016-B — Strict Isolation

**Technique**: Strict Isolation
**Objective**: Verify MOD-008 delegation.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| MOD-008 (extract_ids) | Internal function call | Spy |

**UTS-016-B1 — MOD-008 called twice (added lines, removed lines)**

- **Arrange**: Spy on MOD-008
- **Act**: Call `classify_changes(diff_result)`
- **Assert**: MOD-008 called exactly 2 times, both with `id_type = "REQ"`

---

### MOD-017: resolve_feature_from_branch

#### UTP-017-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise override path, regex match, and regex failure.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained (string parsing) |

**UTS-017-A1 — Environment override used**

- **Arrange**: `branch_name = "main"`, `specify_feature = "001-v-model-mvp"`
- **Act**: Call `resolve_feature_from_branch("main", "001-v-model-mvp")`
- **Assert**: `feature_name = "001-v-model-mvp"`; `vmodel_dir = "specs/001-v-model-mvp/v-model/"`

**UTS-017-A2 — Branch name with feature/ prefix matches**

- **Arrange**: `branch_name = "feature/001-v-model-mvp"`, `specify_feature = ""`
- **Act**: Call `resolve_feature_from_branch("feature/001-v-model-mvp", "")`
- **Assert**: `feature_name = "001-v-model-mvp"`

**UTS-017-A3 — Branch name without prefix matches directly**

- **Arrange**: `branch_name = "003a-design-layers"`, `specify_feature = ""`
- **Act**: Call `resolve_feature_from_branch("003a-design-layers", "")`
- **Assert**: `feature_name = "003a-design-layers"`

**UTS-017-A4 — Non-matching branch raises RESOLUTION_FAILURE**

- **Arrange**: `branch_name = "my-random-branch"`, `specify_feature = ""`
- **Act**: Call `resolve_feature_from_branch("my-random-branch", "")`
- **Assert**: Raises `RESOLUTION_FAILURE`

#### UTP-017-B — Equivalence Partitioning

**Technique**: Equivalence Partitioning
**Objective**: Verify each branch prefix category is handled.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-017-B1 — "feature/" prefix stripped**

- **Arrange**: `branch_name = "feature/005a-hazard-analysis"`
- **Act**: Call `resolve_feature_from_branch(branch_name, "")`
- **Assert**: `feature_name = "005a-hazard-analysis"`

**UTS-017-B2 — "bugfix/" prefix stripped**

- **Arrange**: `branch_name = "bugfix/001-v-model-mvp"`
- **Act**: Call `resolve_feature_from_branch(branch_name, "")`
- **Assert**: `feature_name = "001-v-model-mvp"`

**UTS-017-B3 — "hotfix/" prefix stripped**

- **Arrange**: `branch_name = "hotfix/002-spec-lifecycle"`
- **Act**: Call `resolve_feature_from_branch(branch_name, "")`
- **Assert**: `feature_name = "002-spec-lifecycle"`

---

### MOD-018: validate_prerequisites

#### UTP-018-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise the flag-to-file mapping loop and missing-file branch.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system (file_exists) | External I/O | Stub returning controlled booleans |

**UTS-018-A1 — All required files present**

- **Arrange**: `required_flags = ["--require-reqs", "--require-acceptance"]`. Stub file_exists → `true` for both
- **Act**: Call `validate_prerequisites("vmodel_dir", required_flags)`
- **Assert**: Returns `true`

**UTS-018-A2 — Missing file raises MISSING_PREREQUISITE**

- **Arrange**: `required_flags = ["--require-reqs"]`. Stub file_exists("vmodel_dir/requirements.md") → `false`
- **Act**: Call `validate_prerequisites("vmodel_dir", required_flags)`
- **Assert**: Raises `MISSING_PREREQUISITE` with message containing "requirements.md"

**UTS-018-A3 — Empty flags list (no prerequisites)**

- **Arrange**: `required_flags = []`
- **Act**: Call `validate_prerequisites("vmodel_dir", [])`
- **Assert**: Returns `true` (loop body never entered)

#### UTP-018-B — Strict Isolation

**Technique**: Strict Isolation
**Objective**: Verify file system interaction isolation.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system (file_exists) | External I/O | Spy |

**UTS-018-B1 — file_exists called with correct paths**

- **Arrange**: `required_flags = ["--require-system-design"]`. Spy on file_exists
- **Act**: Call `validate_prerequisites("specs/001/v-model", required_flags)`
- **Assert**: file_exists called once with `"specs/001/v-model/system-design.md"`

---

### MOD-019: scan_vmodel_directory

#### UTP-019-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise loop over KNOWN_DOCS with present and absent files.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system (file_exists) | External I/O | Stub returning controlled booleans per path |

**UTS-019-A1 — All 10 known docs present**

- **Arrange**: Stub file_exists → `true` for all 10 KNOWN_DOCS paths
- **Act**: Call `scan_vmodel_directory("vmodel_dir")`
- **Assert**: Returns array of length 10

**UTS-019-A2 — Only some docs present**

- **Arrange**: Stub file_exists → `true` for "requirements.md", "acceptance-plan.md"; `false` for rest
- **Act**: Call `scan_vmodel_directory("vmodel_dir")`
- **Assert**: Returns `["requirements.md", "acceptance-plan.md"]` (preserving KNOWN_DOCS order)

**UTS-019-A3 — Empty directory (no docs found)**

- **Arrange**: Stub file_exists → `false` for all
- **Act**: Call `scan_vmodel_directory("vmodel_dir")`
- **Assert**: Returns empty array

#### UTP-019-B — Boundary Value Analysis

**Technique**: Boundary Value Analysis
**Objective**: Test document count boundaries.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system (file_exists) | External I/O | Stub |

**UTS-019-B1 — 0 documents (minimum)**

- **Arrange**: Stub file_exists → `false` for all 10
- **Act**: Call `scan_vmodel_directory("vmodel_dir")`
- **Assert**: Returns array of length 0

**UTS-019-B2 — 1 document**

- **Arrange**: Stub file_exists → `true` only for "spec.md"
- **Act**: Call `scan_vmodel_directory("vmodel_dir")`
- **Assert**: Returns array of length 1 containing "spec.md"

**UTS-019-B3 — 10 documents (maximum)**

- **Arrange**: Stub file_exists → `true` for all 10
- **Act**: Call `scan_vmodel_directory("vmodel_dir")`
- **Assert**: Returns array of length 10

#### UTP-019-C — Strict Isolation

**Technique**: Strict Isolation
**Objective**: Verify file system calls use correct path construction.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system (file_exists) | External I/O | Spy |

**UTS-019-C1 — file_exists called 10 times with KNOWN_DOCS paths**

- **Arrange**: Spy on file_exists. `vmodel_dir = "specs/001/v-model"`
- **Act**: Call `scan_vmodel_directory("specs/001/v-model")`
- **Assert**: file_exists called exactly 10 times; first call with `"specs/001/v-model/spec.md"`, last with `"specs/001/v-model/unit-test.md"`

---

### MOD-020: read_vmodel_config

#### UTP-020-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise file-absent, domain-empty, invalid-domain, and valid-domain branches.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system (file_exists, read_file) | External I/O | Stub |
| YAML parser (parse_yaml) | Library call | Stub returning controlled dict |

**UTS-020-A1 — Config file absent returns NULL**

- **Arrange**: Stub file_exists → `false`
- **Act**: Call `read_vmodel_config("repo_root")`
- **Assert**: Returns `NULL`

**UTS-020-A2 — Config present but domain empty returns NULL**

- **Arrange**: Stub file_exists → `true`. Stub parse_yaml → `{"domain": ""}`
- **Act**: Call `read_vmodel_config("repo_root")`
- **Assert**: Returns `NULL`

**UTS-020-A3 — Invalid domain raises INVALID_DOMAIN**

- **Arrange**: Stub parse_yaml → `{"domain": "invalid_standard"}`
- **Act**: Call `read_vmodel_config("repo_root")`
- **Assert**: Raises `INVALID_DOMAIN` with message containing "invalid_standard"

**UTS-020-A4 — Valid domain returned**

- **Arrange**: Stub parse_yaml → `{"domain": "iso_26262"}`
- **Act**: Call `read_vmodel_config("repo_root")`
- **Assert**: Returns `"iso_26262"`

#### UTP-020-B — Equivalence Partitioning

**Technique**: Equivalence Partitioning
**Objective**: Verify each allowed domain value and the invalid partition.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system, YAML parser | External | Stubs |

**UTS-020-B1 — "iso_26262" (valid partition)**

- **Arrange**: Stub parse_yaml → `{"domain": "iso_26262"}`
- **Act**: Call `read_vmodel_config("repo_root")`
- **Assert**: Returns `"iso_26262"`

**UTS-020-B2 — "do_178c" (valid partition)**

- **Arrange**: Stub parse_yaml → `{"domain": "do_178c"}`
- **Act**: Call `read_vmodel_config("repo_root")`
- **Assert**: Returns `"do_178c"`

**UTS-020-B3 — "iec_62304" (valid partition)**

- **Arrange**: Stub parse_yaml → `{"domain": "iec_62304"}`
- **Act**: Call `read_vmodel_config("repo_root")`
- **Assert**: Returns `"iec_62304"`

**UTS-020-B4 — "faa_order_8110" (invalid partition)**

- **Arrange**: Stub parse_yaml → `{"domain": "faa_order_8110"}`
- **Act**: Call `read_vmodel_config("repo_root")`
- **Assert**: Raises `INVALID_DOMAIN`

#### UTP-020-C — Strict Isolation

**Technique**: Strict Isolation
**Objective**: Verify file system and YAML parser isolation.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system (file_exists, read_file) | External I/O | Spy |
| YAML parser (parse_yaml) | Library call | Spy |

**UTS-020-C1 — File system called with correct config path**

- **Arrange**: Spy on file_exists. `repo_root = "/project"`
- **Act**: Call `read_vmodel_config("/project")`
- **Assert**: file_exists called with `"/project/v-model-config.yml"`

**UTS-020-C2 — YAML parse error returns NULL gracefully**

- **Arrange**: Stub read_file → `"not: valid: yaml: [broken"`. Stub parse_yaml → raises YAMLError
- **Act**: Call `read_vmodel_config("repo_root")`
- **Assert**: Returns `NULL` (graceful degradation, not crash)

---

### MOD-021: resolve_overlay_paths

#### UTP-021-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise file-exists/absent branches for both command and template overlays.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system (file_exists, read_file) | External I/O | Stub |

**UTS-021-A1 — Both overlays present**

- **Arrange**: Stub file_exists → `true` for both paths. Stub read_file → "cmd content", "tmpl content"
- **Act**: Call `resolve_overlay_paths("iso_26262", "requirements")`
- **Assert**: `command_overlay = "cmd content"`, `template_overlay = "tmpl content"`

**UTS-021-A2 — Command overlay present, template absent**

- **Arrange**: Stub file_exists → `true` for cmd, `false` for tmpl
- **Act**: Call `resolve_overlay_paths("do_178c", "acceptance")`
- **Assert**: `command_overlay` non-empty; `template_overlay = ""`

**UTS-021-A3 — Both overlays absent**

- **Arrange**: Stub file_exists → `false` for both
- **Act**: Call `resolve_overlay_paths("iec_62304", "hazard-analysis")`
- **Assert**: `command_overlay = ""`, `template_overlay = ""`

#### UTP-021-B — Strict Isolation

**Technique**: Strict Isolation
**Objective**: Verify file system path construction.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system (file_exists, read_file) | External I/O | Spy |

**UTS-021-B1 — Paths constructed with correct domain and command**

- **Arrange**: Spy on file_exists. Domain = "iso_26262", command = "requirements"
- **Act**: Call `resolve_overlay_paths("iso_26262", "requirements")`
- **Assert**: file_exists called with `"commands/overlays/iso_26262/requirements.md"` and `"templates/overlays/iso_26262/requirements-template.md"`

---

### MOD-022: write_markdown_file

#### UTP-022-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise empty-content guard, directory creation, write, and post-write verification.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system (directory_exists, mkdir_p, write_file, file_exists) | External I/O | Stub |

**UTS-022-A1 — Empty content raises WRITE_FAILURE**

- **Arrange**: `content = ""`, `target_path = "out/test.md"`
- **Act**: Call `write_markdown_file("", "out/test.md")`
- **Assert**: Raises `WRITE_FAILURE` with message containing "empty content"

**UTS-022-A2 — Directory created when absent**

- **Arrange**: `content = "# Test"`. Stub directory_exists → `false`. Stub mkdir_p → success. Stub write_file → success. Stub file_exists → `true`
- **Act**: Call `write_markdown_file("# Test", "new_dir/test.md")`
- **Assert**: mkdir_p called with "new_dir"; returns `true`

**UTS-022-A3 — Write success with existing directory**

- **Arrange**: Stub directory_exists → `true`. Stub write_file → success. Stub file_exists → `true`
- **Act**: Call `write_markdown_file("# Test", "existing_dir/test.md")`
- **Assert**: mkdir_p NOT called; returns `true`

**UTS-022-A4 — Post-write verification failure**

- **Arrange**: Stub write_file → success. Stub file_exists (post-write) → `false`
- **Act**: Call `write_markdown_file("# Test", "path/test.md")`
- **Assert**: Raises `WRITE_FAILURE` with message containing "not found after write"

#### UTP-022-B — Strict Isolation

**Technique**: Strict Isolation
**Objective**: Verify file system call sequence and error propagation.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system | External I/O | Controlled stub |

**UTS-022-B1 — IOError during write raises WRITE_FAILURE**

- **Arrange**: Stub write_file → raises IOError("permission denied")
- **Act**: Call `write_markdown_file("# Test", "path/test.md")`
- **Assert**: Raises `WRITE_FAILURE` with message containing "permission denied"

**UTS-022-B2 — Write called with UTF-8 encoding**

- **Arrange**: Spy on write_file
- **Act**: Call `write_markdown_file("# Test 日本語", "path/test.md")`
- **Assert**: write_file called with encoding="UTF-8"

---

### MOD-023: parse_lifecycle_tags

#### UTP-023-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise all 4 tag patterns and the ACTIVE default.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| MOD-008 (extract_ids) | Internal function call | Stub returning controlled ID arrays |

**UTS-023-A1 — No tags → all ACTIVE**

- **Arrange**: Markdown with "REQ-001" and "REQ-002", no lifecycle tags. Stub MOD-008 → `["REQ-001", "REQ-002"]`
- **Act**: Call `parse_lifecycle_tags(markdown_content)`
- **Assert**: Both IDs mapped to `state = "ACTIVE"`

**UTS-023-A2 — DEPRECATED_SUPERSEDED tag detected**

- **Arrange**: Line: `"REQ-001 [DEPRECATED — Superseded by REQ-005]"`. Stub MOD-008 → `["REQ-001"]`
- **Act**: Call `parse_lifecycle_tags(markdown_content)`
- **Assert**: `lifecycle_map["REQ-001"]` = `{state: "DEPRECATED_SUPERSEDED", detail: "REQ-005"}`

**UTS-023-A3 — MODIFIED tag detected**

- **Arrange**: Line: `"REQ-003 [MODIFIED]"`. Stub MOD-008 → `["REQ-003"]`
- **Act**: Call `parse_lifecycle_tags(markdown_content)`
- **Assert**: `lifecycle_map["REQ-003"]` = `{state: "MODIFIED", detail: ""}`

**UTS-023-A4 — SUSPECT tag detected**

- **Arrange**: Line: `"ATP-001-A [SUSPECT — Parent REQ-001 modified]"`. Stub MOD-008 → `["ATP-001-A"]`
- **Act**: Call `parse_lifecycle_tags(markdown_content)`
- **Assert**: `lifecycle_map["ATP-001-A"]` = `{state: "SUSPECT", detail: "REQ-001"}`

#### UTP-023-B — Equivalence Partitioning

**Technique**: Equivalence Partitioning
**Objective**: Verify each lifecycle state partition.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| MOD-008 (extract_ids) | Internal function call | Stub |

**UTS-023-B1 — ACTIVE partition (no tag)**

- **Arrange**: Line with ID but no tag
- **Act**: Call `parse_lifecycle_tags(markdown_content)`
- **Assert**: State = "ACTIVE"

**UTS-023-B2 — DEPRECATED_WITHDRAWN partition**

- **Arrange**: Line: `"REQ-002 [DEPRECATED — Withdrawn: No longer needed]"`
- **Act**: Call `parse_lifecycle_tags(markdown_content)`
- **Assert**: State = "DEPRECATED_WITHDRAWN", detail = "No longer needed"

**UTS-023-B3 — Malformed tag (invalid partition → treated as ACTIVE)**

- **Arrange**: Line: `"REQ-004 [UNKNOWN_TAG]"`
- **Act**: Call `parse_lifecycle_tags(markdown_content)`
- **Assert**: State = "ACTIVE" (malformed tag ignored)

#### UTP-023-C — Strict Isolation

**Technique**: Strict Isolation
**Objective**: Verify MOD-008 delegation.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| MOD-008 (extract_ids) | Internal function call | Spy |

**UTS-023-C1 — MOD-008 called once with markdown content**

- **Arrange**: Spy on MOD-008
- **Act**: Call `parse_lifecycle_tags(markdown_content)`
- **Assert**: MOD-008 called once with the full markdown content

---

### MOD-024: apply_lifecycle_transitions

#### UTP-024-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise valid transitions, invalid transition guard, unknown ID skip, and cascading.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained (in-memory dict operations) |

**UTS-024-A1 — Valid ACTIVE → SUSPECT transition**

- **Arrange**: `lifecycle_map = {"REQ-001": {state: "ACTIVE"}}`. `parent_changes = {"REQ-001": {change_type: "modified"}}`
- **Act**: Call `apply_lifecycle_transitions(lifecycle_map, parent_changes)`
- **Assert**: `transitions[0]` = `{id: "REQ-001", from: "ACTIVE", to: "SUSPECT"}`; map updated

**UTS-024-A2 — Invalid transition raises INVALID_TRANSITION**

- **Arrange**: `lifecycle_map = {"REQ-001": {state: "DEPRECATED_SUPERSEDED"}}`. `parent_changes = {"REQ-001": {change_type: "reactivate"}}`
- **Act**: Call `apply_lifecycle_transitions(lifecycle_map, parent_changes)`
- **Assert**: Raises `INVALID_TRANSITION` (DEPRECATED_SUPERSEDED is terminal)

**UTS-024-A3 — Unknown ID silently skipped**

- **Arrange**: `lifecycle_map = {"REQ-001": {state: "ACTIVE"}}`. `parent_changes = {"REQ-999": {change_type: "modified"}}`
- **Act**: Call `apply_lifecycle_transitions(lifecycle_map, parent_changes)`
- **Assert**: `transitions` is empty; no error raised

**UTS-024-A4 — Cascading transitions within same call**

- **Arrange**: `lifecycle_map = {"REQ-001": {state: "ACTIVE"}, "REQ-002": {state: "ACTIVE"}}`. Both marked as modified
- **Act**: Call `apply_lifecycle_transitions(lifecycle_map, parent_changes)`
- **Assert**: Both transition to SUSPECT; `transitions` has length 2

#### UTP-024-B — State Transition Testing

**Technique**: State Transition Testing
**Objective**: Verify all 8 valid transitions and confirm invalid transitions are rejected. Tests derived from MOD-024 state diagram.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-024-B1 — ACTIVE → SUSPECT (parent modified)**

- **Arrange**: lifecycle_map with ACTIVE item; change_type = modified
- **Act**: Apply transition
- **Assert**: New state = SUSPECT

**UTS-024-B2 — ACTIVE → DEPRECATED_SUPERSEDED**

- **Arrange**: lifecycle_map with ACTIVE item; change_type = supersede(REQ-010)
- **Act**: Apply transition
- **Assert**: New state = DEPRECATED_SUPERSEDED

**UTS-024-B3 — ACTIVE → DEPRECATED_WITHDRAWN**

- **Arrange**: lifecycle_map with ACTIVE item; change_type = withdraw
- **Act**: Apply transition
- **Assert**: New state = DEPRECATED_WITHDRAWN

**UTS-024-B4 — ACTIVE → MODIFIED**

- **Arrange**: lifecycle_map with ACTIVE item; change_type = modify_in_place
- **Act**: Apply transition
- **Assert**: New state = MODIFIED

**UTS-024-B5 — SUSPECT → ACTIVE (confirmed after review)**

- **Arrange**: lifecycle_map with SUSPECT item; change_type = confirm_active
- **Act**: Apply transition
- **Assert**: New state = ACTIVE

**UTS-024-B6 — SUSPECT → DEPRECATED_SUPERSEDED**

- **Arrange**: lifecycle_map with SUSPECT item; change_type = supersede
- **Act**: Apply transition
- **Assert**: New state = DEPRECATED_SUPERSEDED

**UTS-024-B7 — SUSPECT → DEPRECATED_WITHDRAWN**

- **Arrange**: lifecycle_map with SUSPECT item; change_type = withdraw
- **Act**: Apply transition
- **Assert**: New state = DEPRECATED_WITHDRAWN

**UTS-024-B8 — MODIFIED → ACTIVE (modification accepted)**

- **Arrange**: lifecycle_map with MODIFIED item; change_type = accept_modification
- **Act**: Apply transition
- **Assert**: New state = ACTIVE

**UTS-024-B9 — DEPRECATED_SUPERSEDED → any (terminal — rejected)**

- **Arrange**: lifecycle_map with DEPRECATED_SUPERSEDED item; any change_type
- **Act**: Apply transition
- **Assert**: Raises `INVALID_TRANSITION`

**UTS-024-B10 — DEPRECATED_WITHDRAWN → any (terminal — rejected)**

- **Arrange**: lifecycle_map with DEPRECATED_WITHDRAWN item; any change_type
- **Act**: Apply transition
- **Assert**: Raises `INVALID_TRANSITION`

---

### MOD-025: assign_next_id

#### UTP-025-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise empty IDs, existing IDs, gap-skipping behavior.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-025-A1 — Empty existing_ids returns prefix-001**

- **Arrange**: `existing_ids = []`, `prefix = "REQ"`
- **Act**: Call `assign_next_id([], "REQ")`
- **Assert**: Returns `"REQ-001"`

**UTS-025-A2 — Existing IDs return next sequential**

- **Arrange**: `existing_ids = ["REQ-001", "REQ-002", "REQ-003"]`, `prefix = "REQ"`
- **Act**: Call `assign_next_id(existing_ids, "REQ")`
- **Assert**: Returns `"REQ-004"`

**UTS-025-A3 — Gaps not reused**

- **Arrange**: `existing_ids = ["REQ-001", "REQ-005"]` (gap at 002–004), `prefix = "REQ"`
- **Act**: Call `assign_next_id(existing_ids, "REQ")`
- **Assert**: Returns `"REQ-006"` (not REQ-002)

**UTS-025-A4 — Mixed prefix IDs ignored**

- **Arrange**: `existing_ids = ["REQ-001", "ATP-005-A", "REQ-003"]`, `prefix = "REQ"`
- **Act**: Call `assign_next_id(existing_ids, "REQ")`
- **Assert**: Returns `"REQ-004"` (ATP ID ignored by pattern)

#### UTP-025-B — Boundary Value Analysis

**Technique**: Boundary Value Analysis
**Objective**: Test ID number boundaries.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-025-B1 — max_num = 0 (no existing IDs)**

- **Arrange**: `existing_ids = []`
- **Act**: Call `assign_next_id([], "REQ")`
- **Assert**: Returns `"REQ-001"` (next = 0 + 1)

**UTS-025-B2 — max_num = 1 (single ID)**

- **Arrange**: `existing_ids = ["REQ-001"]`
- **Act**: Call `assign_next_id(existing_ids, "REQ")`
- **Assert**: Returns `"REQ-002"`

**UTS-025-B3 — max_num = 999 (3-digit upper boundary)**

- **Arrange**: `existing_ids = ["REQ-999"]`
- **Act**: Call `assign_next_id(existing_ids, "REQ")`
- **Assert**: Returns `"REQ-1000"` (overflows 3-digit format — documents behavior)

---

### MOD-026: resolve_input_mode

#### UTP-026-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise all four input mode branches.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system (read_file) | External I/O | Stub returning mock spec.md content |

**UTS-026-A1 — Combined mode (spec + text)**

- **Arrange**: `available_docs = ["spec.md"]`, `user_arguments = "Extra context"`. Stub read_file → "# Spec content"
- **Act**: Call `resolve_input_mode(available_docs, "Extra context")`
- **Assert**: `mode = "combined"`, `primary_content` = spec content, `supplementary_content` = "Extra context"

**UTS-026-A2 — Spec-only mode**

- **Arrange**: `available_docs = ["spec.md"]`, `user_arguments = ""`
- **Act**: Call `resolve_input_mode(available_docs, "")`
- **Assert**: `mode = "spec_only"`, `supplementary_content = NULL`

**UTS-026-A3 — Text-only mode**

- **Arrange**: `available_docs = ["requirements.md"]` (no "spec.md"), `user_arguments = "Build a login system"`
- **Act**: Call `resolve_input_mode(available_docs, "Build a login system")`
- **Assert**: `mode = "text_only"`, `primary_content` = user text

**UTS-026-A4 — No input raises NO_INPUT**

- **Arrange**: `available_docs = []`, `user_arguments = ""`
- **Act**: Call `resolve_input_mode([], "")`
- **Assert**: Raises `NO_INPUT`

#### UTP-026-B — Equivalence Partitioning

**Technique**: Equivalence Partitioning
**Objective**: Verify each mode partition.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system (read_file) | External I/O | Stub |

**UTS-026-B1 — "combined" partition (both inputs present)**

- **Arrange**: spec.md in available_docs AND non-empty user_arguments
- **Act**: Call `resolve_input_mode(...)`
- **Assert**: `mode = "combined"`

**UTS-026-B2 — "spec_only" partition (spec present, no text)**

- **Arrange**: spec.md in available_docs AND empty user_arguments
- **Act**: Call `resolve_input_mode(...)`
- **Assert**: `mode = "spec_only"`

**UTS-026-B3 — "text_only" partition (no spec, text present)**

- **Arrange**: spec.md NOT in available_docs AND non-empty user_arguments
- **Act**: Call `resolve_input_mode(...)`
- **Assert**: `mode = "text_only"`

#### UTP-026-C — Strict Isolation

**Technique**: Strict Isolation
**Objective**: Verify file system access only when spec.md is present.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| File system (read_file) | External I/O | Spy |

**UTS-026-C1 — read_file called only when spec.md in available_docs**

- **Arrange**: `available_docs = ["spec.md"]`. Spy on read_file
- **Act**: Call `resolve_input_mode(available_docs, "")`
- **Assert**: read_file called once for spec.md

**UTS-026-C2 — read_file NOT called when spec.md absent**

- **Arrange**: `available_docs = []`. Spy on read_file
- **Act**: Call `resolve_input_mode(available_docs, "Some text")`
- **Assert**: read_file not called

---

### MOD-027: format_error_message

#### UTP-027-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise message formatting with and without guidance.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| None | — | Module is self-contained |

**UTS-027-A1 — Error with guidance**

- **Arrange**: `error_category = "MISSING_PREREQUISITE"`, `context = {cause: "File not found", component: "setup-v-model", operation: "validate", guidance: "Run setup script first"}`
- **Act**: Call `format_error_message("MISSING_PREREQUISITE", context)`
- **Assert**: `message` contains "ERROR [MISSING_PREREQUISITE]", "File not found", "Guidance: Run setup script first"; `exit_code = 1`

**UTS-027-A2 — Error without guidance**

- **Arrange**: `context = {cause: "Parse error", component: "build-matrix", operation: "extract", guidance: ""}`
- **Act**: Call `format_error_message("MALFORMED_INPUT", context)`
- **Assert**: `message` does NOT contain "Guidance:"; `exit_code = 1`

**UTS-027-A3 — All context fields present in output**

- **Arrange**: `context` with all fields populated
- **Act**: Call `format_error_message("TEST", context)`
- **Assert**: Output contains "Component:", "Operation:", "Cause:"

---

### MOD-028: check_runtime_capability

#### UTP-028-A — Statement & Branch Coverage

**Technique**: Statement & Branch Coverage
**Objective**: Exercise deterministic, generative-available, generative-unavailable, and unknown capability branches.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| Environment check (environment_has_ai_assistant) | External check | Stub returning controlled boolean |

**UTS-028-A1 — Deterministic capability always available**

- **Arrange**: `capability_check = "deterministic"`
- **Act**: Call `check_runtime_capability("deterministic")`
- **Assert**: `runtime_available = true`; `tool_access` includes file_read, file_write, script_exec

**UTS-028-A2 — Generative capability with AI bound**

- **Arrange**: `capability_check = "generative"`. Stub environment_has_ai_assistant → `true`
- **Act**: Call `check_runtime_capability("generative")`
- **Assert**: `runtime_available = true`

**UTS-028-A3 — Generative capability without AI raises RUNTIME_UNAVAILABLE**

- **Arrange**: `capability_check = "generative"`. Stub environment_has_ai_assistant → `false`
- **Act**: Call `check_runtime_capability("generative")`
- **Assert**: Raises `RUNTIME_UNAVAILABLE`

**UTS-028-A4 — Unknown capability raises INVALID_CAPABILITY**

- **Arrange**: `capability_check = "hybrid"`
- **Act**: Call `check_runtime_capability("hybrid")`
- **Assert**: Raises `INVALID_CAPABILITY` with message containing "hybrid"

#### UTP-028-B — Equivalence Partitioning

**Technique**: Equivalence Partitioning
**Objective**: Verify each capability type partition.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| Environment check | External | Stub |

**UTS-028-B1 — "deterministic" partition (always succeeds)**

- **Arrange**: `capability_check = "deterministic"`
- **Act**: Call `check_runtime_capability("deterministic")`
- **Assert**: Returns success with all tool_access flags true

**UTS-028-B2 — "generative" partition (conditional on AI)**

- **Arrange**: `capability_check = "generative"`. Stub AI → `true`
- **Act**: Call `check_runtime_capability("generative")`
- **Assert**: Returns success

**UTS-028-B3 — Invalid partition (any other string)**

- **Arrange**: `capability_check = "streaming"`
- **Act**: Call `check_runtime_capability("streaming")`
- **Assert**: Raises `INVALID_CAPABILITY`

#### UTP-028-C — Strict Isolation

**Technique**: Strict Isolation
**Objective**: Verify environment check is only called for generative capability.

**Dependency & Mock Registry**

| Dependency | Type | Mock Strategy |
|-----------|------|---------------|
| Environment check (environment_has_ai_assistant) | External | Spy |

**UTS-028-C1 — environment_has_ai_assistant NOT called for deterministic**

- **Arrange**: Spy on environment_has_ai_assistant. `capability_check = "deterministic"`
- **Act**: Call `check_runtime_capability("deterministic")`
- **Assert**: Spy not called

**UTS-028-C2 — environment_has_ai_assistant called once for generative**

- **Arrange**: Spy on environment_has_ai_assistant → `true`. `capability_check = "generative"`
- **Act**: Call `check_runtime_capability("generative")`
- **Assert**: Spy called exactly once

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| **Total UTPs** | 57 |
| **Total UTSs** | 181 |
| **MODs with ≥ 1 UTP** | 28 / 28 (100%) |
| **UTPs with ≥ 1 UTS** | 57 / 57 (100%) |
| **External modules skipped** | 0 |

### Technique Breakdown

| Technique | UTPs | % of Total UTPs |
|-----------|------|-----------------|
| Statement & Branch Coverage | 28 | 49.1% |
| Boundary Value Analysis | 6 | 10.5% |
| Equivalence Partitioning | 8 | 14.0% |
| Strict Isolation | 14 | 24.6% |
| State Transition Testing | 1 | 1.8% |

### MOD → UTP → UTS Mapping

| MOD | Name | UTPs | UTS Count | Techniques |
|-----|------|------|-----------|------------|
| MOD-001 | parse_spec_content | UTP-001-A, UTP-001-B | 8 | S&B, EP |
| MOD-002 | synthesize_requirements | UTP-002-A, UTP-002-B | 7 | S&B, EP |
| MOD-003 | validate_requirement_quality | UTP-003-A, UTP-003-B, UTP-003-C | 11 | S&B, BVA, Isolation |
| MOD-004 | check_banned_terms | UTP-004-A | 4 | S&B |
| MOD-005 | create_requirement_batches | UTP-005-A, UTP-005-B | 8 | S&B, BVA |
| MOD-006 | generate_atp_scn | UTP-006-A, UTP-006-B | 5 | S&B, Isolation |
| MOD-007 | assemble_acceptance_plan | UTP-007-A | 4 | S&B |
| MOD-008 | extract_ids | UTP-008-A, UTP-008-B | 7 | S&B, EP |
| MOD-009 | build_matrix_tables | UTP-009-A, UTP-009-B | 5 | S&B, Isolation |
| MOD-010 | compute_coverage_stats | UTP-010-A, UTP-010-B | 6 | S&B, BVA |
| MOD-011 | find_gaps | UTP-011-A | 4 | S&B |
| MOD-012 | format_exception_report | UTP-012-A | 3 | S&B |
| MOD-013 | compute_bidirectional_coverage | UTP-013-A, UTP-013-B | 5 | S&B, Isolation |
| MOD-014 | format_json_report | UTP-014-A, UTP-014-B | 6 | S&B, BVA |
| MOD-015 | parse_unified_diff | UTP-015-A, UTP-015-B | 5 | S&B, Isolation |
| MOD-016 | classify_changes | UTP-016-A, UTP-016-B | 5 | S&B, Isolation |
| MOD-017 | resolve_feature_from_branch | UTP-017-A, UTP-017-B | 7 | S&B, EP |
| MOD-018 | validate_prerequisites | UTP-018-A, UTP-018-B | 4 | S&B, Isolation |
| MOD-019 | scan_vmodel_directory | UTP-019-A, UTP-019-B, UTP-019-C | 7 | S&B, BVA, Isolation |
| MOD-020 | read_vmodel_config | UTP-020-A, UTP-020-B, UTP-020-C | 10 | S&B, EP, Isolation |
| MOD-021 | resolve_overlay_paths | UTP-021-A, UTP-021-B | 4 | S&B, Isolation |
| MOD-022 | write_markdown_file | UTP-022-A, UTP-022-B | 6 | S&B, Isolation |
| MOD-023 | parse_lifecycle_tags | UTP-023-A, UTP-023-B, UTP-023-C | 8 | S&B, EP, Isolation |
| MOD-024 | apply_lifecycle_transitions | UTP-024-A, UTP-024-B | 14 | S&B, State Transition |
| MOD-025 | assign_next_id | UTP-025-A, UTP-025-B | 7 | S&B, BVA |
| MOD-026 | resolve_input_mode | UTP-026-A, UTP-026-B, UTP-026-C | 9 | S&B, EP, Isolation |
| MOD-027 | format_error_message | UTP-027-A | 3 | S&B |
| MOD-028 | check_runtime_capability | UTP-028-A, UTP-028-B, UTP-028-C | 9 | S&B, EP, Isolation |

### Safety-Critical Techniques

Not applicable — no domain configured in `v-model-config.yml`. MC/DC coverage and fault injection testing would be added via domain overlays (ISO 26262, DO-178C, IEC 62304) when a domain is activated.
