# Unit Test Plan: Domain Overlay Architecture


**Feature Branch**: `feature/006a-domain-overlay`
**Created**: 2025-07-19
**Status**: Draft
**Source**: `specs/006a-domain-overlay/v-model/module-design.md`

## Overview

This document defines the Unit Test Plan for the Domain Overlay Architecture feature. Every module design (MOD-001 through MOD-030) in `module-design.md` has one or more Test Cases (UTP-NNN-X), and every Test Case has one or more executable Unit Scenarios (UTS-NNN-X#) in white-box Arrange/Act/Assert format.

Unit tests verify **internal module logic** — control flow, data transformations, and variable boundaries. They do NOT test module boundaries (integration), user journeys (acceptance), or system-level behavior (system tests). All 30 modules are stateless bash functions; no State Transition Testing is required.

## ID Schema

- **Unit Test Case**: `UTP-{NNN}-{X}` — where NNN matches the parent MOD, X is a letter suffix (A, B, C...)
- **Unit Test Scenario**: `UTS-{NNN}-{X}{#}` — nested under the parent UTP, with numeric suffix (1, 2, 3...)
- Example: `UTS-001-A1` → Scenario 1 of Test Case A verifying MOD-001
- ID lineage: from `UTS-001-A1`, a regex extracts `UTP-001-A` and `MOD-001`. To find the `ARCH-NNN` ancestor, consult the "Parent Architecture Modules" field in `module-design.md`.

## ISO 29119-4 White-Box Techniques

Each test case identifies its technique by name and anchors to a specific module design view:

| Technique | Source View | What It Tests |
|-----------|------------|---------------|
| **Statement & Branch Coverage** | Algorithmic/Logic View | Every line and every True/False branch outcome |
| **Boundary Value Analysis** | Internal Data Structures | Scalar variable boundaries: min-1, min, mid, max, max+1 |
| **Equivalence Partitioning** | Internal Data Structures | Discrete non-scalar types: Booleans, Enums |
| **Strict Isolation** | Architecture Interface View | Every external dependency mocked/stubbed |

Safety-critical techniques (MC/DC Coverage, Variable-Level Fault Injection) omitted — no domain configured.

## Unit Tests

### Module: MOD-001 (create_overlay_directories)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `scripts/bash/overlay/create-overlay-dirs.sh`

#### Test Case: UTP-001-A (Branch Coverage — create_overlay_directories)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches in the directory creation function — parent directory validation, mkdir success/failure, and full-path JSON output.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (directory_exists, mkdir) | OS | Temp directory with controlled structure | Isolate from real filesystem |

* **Unit Scenario: UTS-001-A1** (both parent directories exist — full success path)
  * **Arrange**: Create temp `repo_root` with `commands/` and `templates/` directories present
  * **Act**: Call `create_overlay_directories(repo_root)`
  * **Assert**: Exit code 0; JSON output contains `created_dirs` array with exactly 6 paths; `count` equals 6

* **Unit Scenario: UTS-001-A2** (first parent directory missing — early exit)
  * **Arrange**: Create temp `repo_root` with `templates/` present but `commands/` absent
  * **Act**: Call `create_overlay_directories(repo_root)`
  * **Assert**: Exit code 1; stderr contains `root_not_found`; no directories created under `templates/overlays/`

* **Unit Scenario: UTS-001-A3** (second parent directory missing)
  * **Arrange**: Create temp `repo_root` with `commands/` present but `templates/` absent
  * **Act**: Call `create_overlay_directories(repo_root)`
  * **Assert**: Exit code 1; stderr contains `root_not_found`

* **Unit Scenario: UTS-001-A4** (mkdir failure mid-loop)
  * **Arrange**: Create temp `repo_root` with both parents; make `commands/overlays/` read-only to force mkdir failure
  * **Act**: Call `create_overlay_directories(repo_root)`
  * **Assert**: Exit code 1; stderr contains `Failed to create`

* **Unit Scenario: UTS-001-A5** (idempotent re-execution)
  * **Arrange**: Run `create_overlay_directories(repo_root)` once successfully; all 6 directories exist
  * **Act**: Call `create_overlay_directories(repo_root)` a second time
  * **Assert**: Exit code 0; JSON output identical to first run; no errors

---

### Module: MOD-002 (validate_overlay_structure)

**Parent Architecture Modules**: ARCH-001
**Target Source File(s)**: `scripts/bash/overlay/create-overlay-dirs.sh`

#### Test Case: UTP-002-A (Branch Coverage — validate_overlay_structure)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises all branches in the overlay structure validation — all present, some missing, all missing.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (directory_exists) | OS | Temp directory with controlled structure | Isolate from real filesystem |

* **Unit Scenario: UTS-002-A1** (all 6 directories present)
  * **Arrange**: Create temp `repo_root` with all 6 overlay directories (`commands/overlays/{iso_26262,do_178c,iec_62304}`, `templates/overlays/{iso_26262,do_178c,iec_62304}`)
  * **Act**: Call `validate_overlay_structure(repo_root)`
  * **Assert**: Exit code 0; JSON contains `"valid": true` and `"missing": []`

* **Unit Scenario: UTS-002-A2** (one directory missing)
  * **Arrange**: Create 5 of 6 directories; omit `commands/overlays/do_178c`
  * **Act**: Call `validate_overlay_structure(repo_root)`
  * **Assert**: Exit code 1; JSON contains `"valid": false`; `missing` array contains the omitted path

* **Unit Scenario: UTS-002-A3** (all 6 directories missing)
  * **Arrange**: Create temp `repo_root` with parent dirs but no overlay subdirectories
  * **Act**: Call `validate_overlay_structure(repo_root)`
  * **Assert**: Exit code 1; `missing` array contains exactly 6 paths

#### Test Case: UTP-002-B (Equivalence Partitioning — validation result)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions the `valid` boolean output and the `missing` list into valid/invalid equivalence classes.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (directory_exists) | OS | Temp directory with controlled structure | Isolate from real filesystem |

* **Unit Scenario: UTS-002-B1** (valid partition: true — all dirs exist)
  * **Arrange**: Create all 6 overlay directories
  * **Act**: Call `validate_overlay_structure(repo_root)`
  * **Assert**: `valid` equals `true`; `missing` is empty array

* **Unit Scenario: UTS-002-B2** (valid partition: false — partial dirs)
  * **Arrange**: Create 3 of 6 directories (all command overlays, no template overlays)
  * **Act**: Call `validate_overlay_structure(repo_root)`
  * **Assert**: `valid` equals `false`; `missing` contains exactly 3 template overlay paths

---

### Module: MOD-003 (validate_manifest_schema)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `scripts/bash/overlay/validate-manifest.sh`

#### Test Case: UTP-003-A (Branch Coverage — validate_manifest_schema)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises YAML parse success/failure, missing fields, wrong types, and all-valid branches.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| yq (YAML parser) | External CLI tool | Stub returning controlled YAML output | Isolate from yq binary availability |

* **Unit Scenario: UTS-003-A1** (valid manifest — all fields correct)
  * **Arrange**: Create manifest file with `name: "test"`, `standards: ["ISO 26262"]`, `classification: "automotive"`, `commands: ["trace"]`
  * **Act**: Call `validate_manifest_schema(manifest_path)`
  * **Assert**: Exit code 0; JSON contains `"valid": true` and `"errors": []`

* **Unit Scenario: UTS-003-A2** (YAML parse error)
  * **Arrange**: Create manifest file with invalid YAML content (e.g., unmatched brackets)
  * **Act**: Call `validate_manifest_schema(manifest_path)`
  * **Assert**: Exit code 1; stderr contains `yaml_parse_error`

* **Unit Scenario: UTS-003-A3** (missing required field — `standards` absent)
  * **Arrange**: Create manifest with `name`, `classification`, `commands` but no `standards`
  * **Act**: Call `validate_manifest_schema(manifest_path)`
  * **Assert**: Exit code 1; `errors` array contains `"Missing required field: standards"`

* **Unit Scenario: UTS-003-A4** (wrong field type — `standards` as string instead of list)
  * **Arrange**: Create manifest with `standards: "ISO 26262"` (string, not list)
  * **Act**: Call `validate_manifest_schema(manifest_path)`
  * **Assert**: Exit code 1; `errors` array contains `"Field 'standards' must be a list"`

* **Unit Scenario: UTS-003-A5** (multiple errors — two fields missing and one wrong type)
  * **Arrange**: Create manifest missing `name` and `classification`, with `commands: "trace"` (string)
  * **Act**: Call `validate_manifest_schema(manifest_path)`
  * **Assert**: Exit code 1; `errors` array length equals 3

#### Test Case: UTP-003-B (BVA — errors accumulator)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests boundary conditions on the `errors` list size, which determines the `valid` boolean.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| yq (YAML parser) | External CLI tool | Stub returning controlled YAML output | Isolate from yq binary availability |

* **Unit Scenario: UTS-003-B1** (min-1: errors = -1 — not reachable; substitute with 0 errors)
  * **Arrange**: Create manifest with all 4 required fields present and correctly typed
  * **Act**: Call `validate_manifest_schema(manifest_path)`
  * **Assert**: `errors` length equals 0; `valid` is `true`; exit code 0

* **Unit Scenario: UTS-003-B2** (min: errors = 1 — single field missing)
  * **Arrange**: Create manifest missing only `classification`
  * **Act**: Call `validate_manifest_schema(manifest_path)`
  * **Assert**: `errors` length equals 1; `valid` is `false`; exit code 1

* **Unit Scenario: UTS-003-B3** (mid: errors = 2)
  * **Arrange**: Create manifest missing `name` and with `commands` as string
  * **Act**: Call `validate_manifest_schema(manifest_path)`
  * **Assert**: `errors` length equals 2; `valid` is `false`

* **Unit Scenario: UTS-003-B4** (max: errors = 4 — all fields missing)
  * **Arrange**: Create manifest with no required fields (empty YAML object)
  * **Act**: Call `validate_manifest_schema(manifest_path)`
  * **Assert**: `errors` length equals 4; `valid` is `false`

* **Unit Scenario: UTS-003-B5** (max+1: errors = 8 — all missing + all wrong types)
  * **Arrange**: Not reachable — a field cannot be both missing and wrong-typed. Max is 4.
  * **Act**: N/A
  * **Assert**: Boundary confirmed at 4; no scenario needed beyond max

#### Test Case: UTP-003-C (Strict Isolation — yq dependency)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies that `yq` is the sole external dependency and that the function behaves correctly when `yq` is stubbed to return controlled outputs.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| yq (YAML parser) | External CLI tool | Stub: function override returning predefined YAML content | Validate logic independent of yq version |

* **Unit Scenario: UTS-003-C1** (yq stub returns valid parsed content)
  * **Arrange**: Override `yq_read` to return `{name: "test", standards: ["a"], classification: "b", commands: ["c"]}`
  * **Act**: Call `validate_manifest_schema(manifest_path)`
  * **Assert**: Exit code 0; function never invokes real `yq` binary

* **Unit Scenario: UTS-003-C2** (yq stub returns parse error)
  * **Arrange**: Override `yq_read` to return exit code 1 with parse_error marker
  * **Act**: Call `validate_manifest_schema(manifest_path)`
  * **Assert**: Exit code 1; stderr contains `yaml_parse_error`; no file system writes occur

---

### Module: MOD-004 (cross_reference_manifest_files)

**Parent Architecture Modules**: ARCH-002
**Target Source File(s)**: `scripts/bash/overlay/validate-manifest.sh`

#### Test Case: UTP-004-A (Branch Coverage — cross_reference_manifest_files)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises orphan detection, unlisted file detection, empty list branches, and YAML parse error.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| yq (YAML parser) | External CLI tool | Stub returning controlled commands list | Isolate from yq |
| Filesystem (list_files) | OS | Temp directory with controlled .md files | Deterministic file listing |

* **Unit Scenario: UTS-004-A1** (perfect match — no orphans, no unlisted)
  * **Arrange**: Create manifest listing `["trace", "audit-report"]`; place `trace.md` and `audit-report.md` in directory
  * **Act**: Call `cross_reference_manifest_files(manifest_path, directory)`
  * **Assert**: Exit code 0; `orphan_entries` is empty; `unlisted_files` is empty

* **Unit Scenario: UTS-004-A2** (orphan entry — manifest lists command with no file)
  * **Arrange**: Create manifest listing `["trace", "missing-cmd"]`; only `trace.md` in directory
  * **Act**: Call `cross_reference_manifest_files(manifest_path, directory)`
  * **Assert**: `orphan_entries` contains `"missing-cmd"`; `unlisted_files` is empty

* **Unit Scenario: UTS-004-A3** (unlisted file — file exists but not in manifest)
  * **Arrange**: Create manifest listing `["trace"]`; place `trace.md` and `extra.md` in directory
  * **Act**: Call `cross_reference_manifest_files(manifest_path, directory)`
  * **Assert**: `unlisted_files` contains `"extra.md"`; `orphan_entries` is empty

* **Unit Scenario: UTS-004-A4** (YAML parse error on commands field)
  * **Arrange**: Create manifest with malformed `commands` field
  * **Act**: Call `cross_reference_manifest_files(manifest_path, directory)`
  * **Assert**: Exit code 1; stderr contains `yaml_parse_error`

#### Test Case: UTP-004-B (Strict Isolation — yq dependency)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies `yq_read_field` is properly stubbed for the `.commands[]` path extraction.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| yq (yq_read_field) | External CLI tool | Stub returning controlled list output | Isolate from yq binary |

* **Unit Scenario: UTS-004-B1** (yq stub returns three commands)
  * **Arrange**: Override `yq_read_field` to return `"trace\naudit-report\nhazard-analysis"`; create matching .md files
  * **Act**: Call `cross_reference_manifest_files(manifest_path, directory)`
  * **Assert**: Both `orphan_entries` and `unlisted_files` are empty; real `yq` never invoked

---

### Module: MOD-005 (collect_overlay_file_list)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `scripts/bash/overlay/generate-manifest.sh`

#### Test Case: UTP-005-A (Branch Coverage — collect_overlay_file_list)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises directory existence check, .md file filtering, _domain.yml exclusion, empty directory error, and sorted output.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (directory_exists, list_directory) | OS | Temp directory with controlled files | Deterministic listing |

* **Unit Scenario: UTS-005-A1** (directory with multiple .md files)
  * **Arrange**: Create temp directory with `trace.md`, `audit-report.md`, `hazard-analysis.md`
  * **Act**: Call `collect_overlay_file_list(domain_dir)`
  * **Assert**: Exit code 0; `files` array is `["audit-report.md", "hazard-analysis.md", "trace.md"]` (sorted); `count` equals 3

* **Unit Scenario: UTS-005-A2** (directory not found)
  * **Arrange**: Set `domain_dir` to `/nonexistent/path`
  * **Act**: Call `collect_overlay_file_list(domain_dir)`
  * **Assert**: Exit code 1; stderr contains `Directory not found`

* **Unit Scenario: UTS-005-A3** (directory with no .md files)
  * **Arrange**: Create empty temp directory (or directory with only `.txt` files)
  * **Act**: Call `collect_overlay_file_list(domain_dir)`
  * **Assert**: Exit code 1; stderr contains `No .md files found`

* **Unit Scenario: UTS-005-A4** (_domain.yml excluded from results)
  * **Arrange**: Create directory with `trace.md` and `_domain.yml`
  * **Act**: Call `collect_overlay_file_list(domain_dir)`
  * **Assert**: `files` contains only `"trace.md"`; `_domain.yml` not in output

#### Test Case: UTP-005-B (BVA — files count)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests boundary of `files` list size constraint (≥1 required for success).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp directory with controlled files | Boundary testing |

* **Unit Scenario: UTS-005-B1** (min-1: 0 files — error boundary)
  * **Arrange**: Create empty temp directory
  * **Act**: Call `collect_overlay_file_list(domain_dir)`
  * **Assert**: Exit code 1; `files` not in output

* **Unit Scenario: UTS-005-B2** (min: 1 file — exact minimum)
  * **Arrange**: Create directory with exactly one file: `trace.md`
  * **Act**: Call `collect_overlay_file_list(domain_dir)`
  * **Assert**: Exit code 0; `count` equals 1

* **Unit Scenario: UTS-005-B3** (mid: 5 files — typical usage)
  * **Arrange**: Create directory with 5 .md files
  * **Act**: Call `collect_overlay_file_list(domain_dir)`
  * **Assert**: Exit code 0; `count` equals 5; array is sorted

* **Unit Scenario: UTS-005-B4** (max: 14 files — full command set)
  * **Arrange**: Create directory with 14 .md files matching all command names
  * **Act**: Call `collect_overlay_file_list(domain_dir)`
  * **Assert**: Exit code 0; `count` equals 14

* **Unit Scenario: UTS-005-B5** (max+1: 15 files — beyond expected set)
  * **Arrange**: Create directory with 15 .md files (14 known + 1 extra)
  * **Act**: Call `collect_overlay_file_list(domain_dir)`
  * **Assert**: Exit code 0; function accepts unbounded count; `count` equals 15

---

### Module: MOD-006 (generate_domain_manifest)

**Parent Architecture Modules**: ARCH-003
**Target Source File(s)**: `scripts/bash/overlay/generate-manifest.sh`

#### Test Case: UTP-006-A (Branch Coverage — generate_domain_manifest)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises domain metadata lookup, MOD-005 delegation, YAML assembly, MOD-003 validation, MOD-004 cross-reference, and error paths.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| MOD-005 (collect_overlay_file_list) | Sibling function | Stub returning controlled file list JSON | Isolate from filesystem scan |
| MOD-003 (validate_manifest_schema) | Sibling function | Stub returning exit code 0 | Isolate from YAML validation |
| MOD-004 (cross_reference_manifest_files) | Sibling function | Stub returning exit code 0 | Isolate from cross-reference logic |

* **Unit Scenario: UTS-006-A1** (valid domain — iso_26262, files present)
  * **Arrange**: Stub MOD-005 to return `{"files": ["trace.md"], "count": 1}`; stub MOD-003 to return exit 0; stub MOD-004 to return exit 0
  * **Act**: Call `generate_domain_manifest("iso_26262", domain_dir)`
  * **Assert**: Exit code 0; `_domain.yml` written with `name: "ISO 26262"`, `standards` list, `classification: "automotive"`, `commands: ["trace"]`

* **Unit Scenario: UTS-006-A2** (unknown domain_id)
  * **Arrange**: Set `domain_id` to `"unknown_domain"`
  * **Act**: Call `generate_domain_manifest("unknown_domain", domain_dir)`
  * **Assert**: Exit code 1; stderr contains `Unknown domain`

* **Unit Scenario: UTS-006-A3** (MOD-005 returns error — no overlay files)
  * **Arrange**: Stub MOD-005 to return exit code 1
  * **Act**: Call `generate_domain_manifest("iso_26262", domain_dir)`
  * **Assert**: Exit code 1; no `_domain.yml` file created

* **Unit Scenario: UTS-006-A4** (MOD-003 validation fails)
  * **Arrange**: Stub MOD-005 to return valid files; stub MOD-003 to return exit code 1
  * **Act**: Call `generate_domain_manifest("iso_26262", domain_dir)`
  * **Assert**: Exit code 1; stderr contains `validation_failed`

#### Test Case: UTP-006-B (Strict Isolation — sibling MOD dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-005, MOD-003, and MOD-004 are all properly stubbed and never execute real logic.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| MOD-005 | ARCH-003 | Function stub with call counter | Verify exactly one invocation |
| MOD-003 | ARCH-002 | Function stub with call counter | Verify called after YAML write |
| MOD-004 | ARCH-002 | Function stub with call counter | Verify called after validation |

* **Unit Scenario: UTS-006-B1** (all three stubs invoked in correct order)
  * **Arrange**: Set up call-tracking stubs for MOD-005, MOD-003, MOD-004; domain_id = `"do_178c"`
  * **Act**: Call `generate_domain_manifest("do_178c", domain_dir)`
  * **Assert**: MOD-005 called once; MOD-003 called once after file write; MOD-004 called once after MOD-003; no real sibling functions executed

* **Unit Scenario: UTS-006-B2** (MOD-005 failure prevents MOD-003/MOD-004 invocation)
  * **Arrange**: Stub MOD-005 to fail; set up call counters for MOD-003 and MOD-004
  * **Act**: Call `generate_domain_manifest("iec_62304", domain_dir)`
  * **Assert**: MOD-003 call count equals 0; MOD-004 call count equals 0


---

### Module: MOD-007 (inject_config_domain_field)

**Parent Architecture Modules**: ARCH-004
**Target Source File(s)**: `scripts/bash/overlay/inject-config-domain.sh`

#### Test Case: UTP-007-A (Branch Coverage — inject_config_domain_field)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises file existence check, duplicate field detection (idempotent skip), and successful injection.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (file_exists, read_file, append_to_file) | OS | Temp file with controlled content | Isolate from real config |

* **Unit Scenario: UTS-007-A1** (file exists, no domain field — injection succeeds)
  * **Arrange**: Create temp `config-template.yml` with content `project_name: test` (no domain field)
  * **Act**: Call `inject_config_domain_field(config_template_path)`
  * **Assert**: Exit code 0; file now contains `# domain: iso_26262` (commented out); stdout contains `Injected domain field`

* **Unit Scenario: UTS-007-A2** (file not found)
  * **Arrange**: Set `config_template_path` to nonexistent path
  * **Act**: Call `inject_config_domain_field(config_template_path)`
  * **Assert**: Exit code 1; stderr contains `file_not_found`

* **Unit Scenario: UTS-007-A3** (domain field already present — idempotent skip)
  * **Arrange**: Create temp config file containing `# domain: iso_26262` already
  * **Act**: Call `inject_config_domain_field(config_template_path)`
  * **Assert**: Exit code 0; stdout contains `already present — skipping`; file content unchanged

* **Unit Scenario: UTS-007-A4** (uncommented domain field present)
  * **Arrange**: Create temp config file containing `domain: do_178c`
  * **Act**: Call `inject_config_domain_field(config_template_path)`
  * **Assert**: Exit code 0; stdout contains `already present — skipping`; file content unchanged (regex matches `^#?\s*domain:`)

#### Test Case: UTP-007-B (Equivalence Partitioning — domain field presence)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions the `content contains regex "^#?\s*domain:"` boolean check into present/absent classes.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp file with controlled content | Partition testing |

* **Unit Scenario: UTS-007-B1** (partition: field absent — content has no domain-related lines)
  * **Arrange**: Create config with `project_name: test\nversion: 1`
  * **Act**: Call `inject_config_domain_field(config_template_path)`
  * **Assert**: File grows by ~6 lines (domain block appended)

* **Unit Scenario: UTS-007-B2** (partition: field present — commented)
  * **Arrange**: Create config with `# domain: iec_62304`
  * **Act**: Call `inject_config_domain_field(config_template_path)`
  * **Assert**: File size unchanged; function returns immediately

* **Unit Scenario: UTS-007-B3** (partition: field present — uncommented with value)
  * **Arrange**: Create config with `domain: iso_26262`
  * **Act**: Call `inject_config_domain_field(config_template_path)`
  * **Assert**: File size unchanged; value preserved as-is

---

### Module: MOD-008 (resolve_domain_field)

**Parent Architecture Modules**: ARCH-005
**Target Source File(s)**: `scripts/bash/overlay/resolve-domain.sh`

#### Test Case: UTP-008-A (Branch Coverage — resolve_domain_field)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises config file missing, domain field absent/empty, unsupported value, and three valid domain values.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| yq (YAML parser) | External CLI tool | Stub returning controlled domain value | Isolate from yq |
| Filesystem (file_exists) | OS | Temp directory with/without config file | Control config presence |

* **Unit Scenario: UTS-008-A1** (config file missing — graceful null)
  * **Arrange**: Set `repo_root` to directory with no `v-model-config.yml`
  * **Act**: Call `resolve_domain_field(repo_root)`
  * **Assert**: Exit code 0; JSON contains `"domain_id": null`, `"reason": "config_not_found"`

* **Unit Scenario: UTS-008-A2** (domain field absent — graceful null)
  * **Arrange**: Create `v-model-config.yml` with `project: test` (no domain field)
  * **Act**: Call `resolve_domain_field(repo_root)`
  * **Assert**: Exit code 0; JSON contains `"domain_id": null`, `"reason": "field_absent_or_empty"`

* **Unit Scenario: UTS-008-A3** (domain field empty string)
  * **Arrange**: Create config with `domain: ""`
  * **Act**: Call `resolve_domain_field(repo_root)`
  * **Assert**: Exit code 0; JSON contains `"domain_id": null`, `"reason": "field_absent_or_empty"`

* **Unit Scenario: UTS-008-A4** (unsupported domain value)
  * **Arrange**: Create config with `domain: mil_std_882`
  * **Act**: Call `resolve_domain_field(repo_root)`
  * **Assert**: Exit code 0; JSON contains `"domain_id": null`, `"reason": "unsupported_value"`, `"value": "mil_std_882"`

* **Unit Scenario: UTS-008-A5** (valid domain — iso_26262)
  * **Arrange**: Create config with `domain: iso_26262`
  * **Act**: Call `resolve_domain_field(repo_root)`
  * **Assert**: Exit code 0; `domain_id` equals `"iso_26262"`; `overlay_paths.commands` ends with `/commands/overlays/iso_26262`

#### Test Case: UTP-008-B (Equivalence Partitioning — domain_value enum)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions `domain_value` into the 3 valid enum values, null, empty, and unsupported.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| yq | External CLI tool | Stub per partition | Controlled domain values |

* **Unit Scenario: UTS-008-B1** (valid: iso_26262)
  * **Arrange**: Stub yq to return `"iso_26262"`
  * **Act**: Call `resolve_domain_field(repo_root)`
  * **Assert**: `domain_id` equals `"iso_26262"`; overlay paths constructed

* **Unit Scenario: UTS-008-B2** (valid: do_178c)
  * **Arrange**: Stub yq to return `"do_178c"`
  * **Act**: Call `resolve_domain_field(repo_root)`
  * **Assert**: `domain_id` equals `"do_178c"`; overlay paths constructed

* **Unit Scenario: UTS-008-B3** (valid: iec_62304)
  * **Arrange**: Stub yq to return `"iec_62304"`
  * **Act**: Call `resolve_domain_field(repo_root)`
  * **Assert**: `domain_id` equals `"iec_62304"`; overlay paths constructed

* **Unit Scenario: UTS-008-B4** (invalid: unsupported value)
  * **Arrange**: Stub yq to return `"as9100"`
  * **Act**: Call `resolve_domain_field(repo_root)`
  * **Assert**: `domain_id` is `null`; `reason` is `"unsupported_value"`

* **Unit Scenario: UTS-008-B5** (invalid: null)
  * **Arrange**: Stub yq to return empty/null
  * **Act**: Call `resolve_domain_field(repo_root)`
  * **Assert**: `domain_id` is `null`; `reason` is `"field_absent_or_empty"`

#### Test Case: UTP-008-C (Strict Isolation — yq dependency)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies `yq_read_field` is the sole external dependency and all resolution logic works with stubbed output.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| yq (yq_read_field) | External CLI tool | Function override with call tracker | Verify single invocation |

* **Unit Scenario: UTS-008-C1** (yq invoked exactly once for domain field)
  * **Arrange**: Set up call-tracking stub for `yq_read_field`; create config file with `domain: iso_26262`
  * **Act**: Call `resolve_domain_field(repo_root)`
  * **Assert**: `yq_read_field` call count equals 1; called with path `.domain`; no real yq process spawned

---

### Module: MOD-009 (scan_domain_terms)

**Parent Architecture Modules**: ARCH-006
**Target Source File(s)**: `scripts/bash/refactor/scan-domain-terms.sh`

#### Test Case: UTP-009-A (Branch Coverage — scan_domain_terms)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises file existence check, line-by-line scanning, term match accumulation, context truncation, and clean-file path.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (file_exists, read_lines) | OS | Temp file with controlled content | Deterministic scan targets |

* **Unit Scenario: UTS-009-A1** (file not found)
  * **Arrange**: Set `file_path` to nonexistent path
  * **Act**: Call `scan_domain_terms(file_path)`
  * **Assert**: Exit code 1; stderr contains `file_not_found`

* **Unit Scenario: UTS-009-A2** (clean file — no banned terms)
  * **Arrange**: Create temp file with content `"Generate test cases for all modules\nVerify coverage is 100%"`
  * **Act**: Call `scan_domain_terms(file_path)`
  * **Assert**: Exit code 0; `is_clean` is `true`; `scan_report` is empty list

* **Unit Scenario: UTS-009-A3** (file with single banned term)
  * **Arrange**: Create temp file with line `"Verify ASIL-D compliance for safety"`
  * **Act**: Call `scan_domain_terms(file_path)`
  * **Assert**: Exit code 0; `is_clean` is `false`; `scan_report` contains 1 entry with `term: "ASIL"`, `line_number: 1`

* **Unit Scenario: UTS-009-A4** (file with multiple terms on same line)
  * **Arrange**: Create temp file with `"Check ASIL and MC/DC per ISO 26262"`
  * **Act**: Call `scan_domain_terms(file_path)`
  * **Assert**: `scan_report` contains 3 entries (ASIL, MC/DC, ISO 26262) all at line 1

* **Unit Scenario: UTS-009-A5** (context truncation at 120 chars)
  * **Arrange**: Create temp file with a 200-character line containing `ASIL` at position 100
  * **Act**: Call `scan_domain_terms(file_path)`
  * **Assert**: `context` field length ≤123 chars (120 + "..."); term still reported

#### Test Case: UTP-009-B (BVA — context length truncation)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests the 120-character context truncation boundary.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp file with controlled line lengths | Boundary testing |

* **Unit Scenario: UTS-009-B1** (min-1: line of 119 chars containing ASIL)
  * **Arrange**: Create file with 119-char line containing `ASIL`
  * **Act**: Call `scan_domain_terms(file_path)`
  * **Assert**: `context` equals full line (no truncation); no `...` suffix

* **Unit Scenario: UTS-009-B2** (min: line of exactly 120 chars)
  * **Arrange**: Create file with 120-char line containing `MISRA`
  * **Act**: Call `scan_domain_terms(file_path)`
  * **Assert**: `context` equals full line (120 chars, no truncation)

* **Unit Scenario: UTS-009-B3** (mid: line of 150 chars)
  * **Arrange**: Create file with 150-char line containing `DO-178C`
  * **Act**: Call `scan_domain_terms(file_path)`
  * **Assert**: `context` is 123 chars (120 + `...`)

* **Unit Scenario: UTS-009-B4** (max: line of 500 chars)
  * **Arrange**: Create file with 500-char line containing `IEC 62304`
  * **Act**: Call `scan_domain_terms(file_path)`
  * **Assert**: `context` is 123 chars (120 + `...`)

* **Unit Scenario: UTS-009-B5** (max+1: N/A — no upper limit on line length; truncation always applies)
  * **Arrange**: N/A — boundary is one-sided (context capped at 120)
  * **Act**: N/A
  * **Assert**: Confirmed truncation works at 120; no additional boundary exists

#### Test Case: UTP-009-C (Equivalence Partitioning — is_clean boolean)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions the `is_clean` boolean into true (no matches) and false (≥1 matches).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp file with controlled content | Partition testing |

* **Unit Scenario: UTS-009-C1** (partition: is_clean = true)
  * **Arrange**: Create file with no banned terms
  * **Act**: Call `scan_domain_terms(file_path)`
  * **Assert**: `is_clean` is `true`; `scan_report` length equals 0

* **Unit Scenario: UTS-009-C2** (partition: is_clean = false)
  * **Arrange**: Create file with `"WCET analysis required"`
  * **Act**: Call `scan_domain_terms(file_path)`
  * **Assert**: `is_clean` is `false`; `scan_report` length ≥1

---

### Module: MOD-010 (clean_mixed_command_sections)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `scripts/bash/refactor/clean-mixed-commands.sh`

#### Test Case: UTP-010-A (Branch Coverage — clean_mixed_command_sections)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises MIXED command validation, heading-level section detection, ad-hoc conditional pattern detection, section-end detection, and reverse-order removal.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (read_lines, write_file) | OS | Temp command file with controlled sections | Isolate from real commands |

* **Unit Scenario: UTS-010-A1** (not a MIXED command — rejected)
  * **Arrange**: Set `command_path` to a file named `requirements.md`
  * **Act**: Call `clean_mixed_command_sections(command_path, [])`
  * **Assert**: Returns `{"error": "invalid_target"}`; file unchanged

* **Unit Scenario: UTS-010-A2** (MIXED command with one heading-level domain section)
  * **Arrange**: Create `system-design.md` with 50 lines; lines 20-30 contain `### 5.1 Safety-Critical Techniques` section
  * **Act**: Call `clean_mixed_command_sections(command_path, scan_report)`
  * **Assert**: `sections_removed` equals 1; `lines_removed` equals 11; total line count is 39

* **Unit Scenario: UTS-010-A3** (ad-hoc conditional pattern detected)
  * **Arrange**: Create `unit-test.md` with line `**If domain is set**, include MC/DC tables` followed by blank line
  * **Act**: Call `clean_mixed_command_sections(command_path, scan_report)`
  * **Assert**: `sections_removed` ≥1; the ad-hoc conditional line removed

* **Unit Scenario: UTS-010-A4** (domain section extends to end of file)
  * **Arrange**: Create `module-design.md` where lines 40-50 (last 11 lines) form a domain section with no subsequent heading
  * **Act**: Call `clean_mixed_command_sections(command_path, scan_report)`
  * **Assert**: `lines_removed` equals 11; file ends at line 39

* **Unit Scenario: UTS-010-A5** (no domain sections found — clean file)
  * **Arrange**: Create `integration-test.md` with no domain-specific headings or conditionals
  * **Act**: Call `clean_mixed_command_sections(command_path, scan_report)`
  * **Assert**: `sections_removed` equals 0; `lines_removed` equals 0; file unchanged

#### Test Case: UTP-010-B (BVA — section_depth range)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests the `section_depth` variable boundary (0-6), which determines heading-level vs block-level section parsing.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp command file | Boundary testing |

* **Unit Scenario: UTS-010-B1** (section_depth = 0 — block-level conditional, ends at blank line)
  * **Arrange**: Create `system-test.md` with ad-hoc `If domain is set...` block followed by blank line after 3 content lines
  * **Act**: Call `clean_mixed_command_sections(command_path, scan_report)`
  * **Assert**: 4 lines removed (conditional + 3 content + blank); section_depth was 0

* **Unit Scenario: UTS-010-B2** (section_depth = 2 — `##` level heading)
  * **Arrange**: Create file with `## Safety-Critical Memory Management` section (depth 2) ending at next `##` heading
  * **Act**: Call `clean_mixed_command_sections(command_path, scan_report)`
  * **Assert**: Section between headings removed; section_depth was 2

* **Unit Scenario: UTS-010-B3** (section_depth = 4 — `####` level heading)
  * **Arrange**: Create file with `#### 3.2.1 Single-Entry/Single-Exit Constraints` section (depth 4)
  * **Act**: Call `clean_mixed_command_sections(command_path, scan_report)`
  * **Assert**: Section removed; parsing correctly identifies depth-4 boundaries

---

### Module: MOD-011 (strip_mixed_command_references)

**Parent Architecture Modules**: ARCH-007
**Target Source File(s)**: `scripts/bash/refactor/clean-mixed-commands.sh`

#### Test Case: UTP-011-A (Branch Coverage — strip_mixed_command_references)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises domain standard removal, retained standard preservation, regulatory-grade qualifier removal, and whitespace cleanup.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (read_lines, write_file) | OS | Temp file with controlled references | Isolate from real commands |

* **Unit Scenario: UTS-011-A1** (line with single domain standard reference)
  * **Arrange**: Create file with line `"Generate per ISO 26262 and IEEE 1016."`
  * **Act**: Call `strip_mixed_command_references(command_path)`
  * **Assert**: `replacements` equals 1; line becomes `"Generate per IEEE 1016."` (ISO 26262 removed, IEEE 1016 retained)

* **Unit Scenario: UTS-011-A2** (line with multiple domain standards)
  * **Arrange**: Create file with `"Comply with DO-178C, ISO 26262, and IEC 62304 requirements."`
  * **Act**: Call `strip_mixed_command_references(command_path)`
  * **Assert**: `replacements` equals 1; all three domain standards removed; `requirements.` preserved

* **Unit Scenario: UTS-011-A3** (regulatory-grade qualifier)
  * **Arrange**: Create file with `"Produce regulatory-grade traceability matrix."`
  * **Act**: Call `strip_mixed_command_references(command_path)`
  * **Assert**: Line becomes `"Produce traceability matrix."`; no double spaces remain

* **Unit Scenario: UTS-011-A4** (no replacements needed)
  * **Arrange**: Create file with only generic language and retained standards (IEEE, ISO 29119)
  * **Act**: Call `strip_mixed_command_references(command_path)`
  * **Assert**: `replacements` equals 0; file content unchanged

#### Test Case: UTP-011-B (BVA — replacements count)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests boundary of `replacements` counter (≥0).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp file with controlled content | Boundary testing |

* **Unit Scenario: UTS-011-B1** (min: 0 replacements — clean file)
  * **Arrange**: Create file with no domain standards
  * **Act**: Call `strip_mixed_command_references(command_path)`
  * **Assert**: `replacements` equals 0

* **Unit Scenario: UTS-011-B2** (min+1: 1 replacement)
  * **Arrange**: Create file with one line containing `MISRA` reference
  * **Act**: Call `strip_mixed_command_references(command_path)`
  * **Assert**: `replacements` equals 1

* **Unit Scenario: UTS-011-B3** (mid: 5 replacements across multiple lines)
  * **Arrange**: Create file with 5 lines each containing one domain standard
  * **Act**: Call `strip_mixed_command_references(command_path)`
  * **Assert**: `replacements` equals 5

---

### Module: MOD-012 (clean_hardcoded_command_content)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `scripts/bash/refactor/clean-hardcoded-commands.sh`

#### Test Case: UTP-012-A (Branch Coverage — clean_hardcoded_command_content)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises HARDCODED command validation, regulatory-grade replacement, standalone citation removal, Freedom from Interference prose removal, and blank-line cleanup.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (read_lines, write_file) | OS | Temp file with controlled content | Isolate from real commands |

* **Unit Scenario: UTS-012-A1** (not a HARDCODED command — rejected)
  * **Arrange**: Set `command_path` to `system-design.md`
  * **Act**: Call `clean_hardcoded_command_content(command_path, [])`
  * **Assert**: Returns `{"error": "invalid_target"}`

* **Unit Scenario: UTS-012-A2** (regulatory-grade replaced with specification-grade)
  * **Arrange**: Create `trace.md` with `"Produce regulatory-grade output"`
  * **Act**: Call `clean_hardcoded_command_content(command_path, [])`
  * **Assert**: Line reads `"Produce specification-grade output"`; `lines_added` equals 1

* **Unit Scenario: UTS-012-A3** (standalone citation removed — line becomes blank)
  * **Arrange**: Create `hazard-analysis.md` with line `"  comply with ISO 26262 Part 9."`
  * **Act**: Call `clean_hardcoded_command_content(command_path, [])`
  * **Assert**: `lines_removed` ≥1; blank line marked for removal

* **Unit Scenario: UTS-012-A4** (Freedom from Interference prose removed)
  * **Arrange**: Create `peer-review.md` with `"Verify Freedom from Interference between partitions. Then check outputs."`
  * **Act**: Call `clean_hardcoded_command_content(command_path, [])`
  * **Assert**: Freedom from Interference sentence removed; `"Then check outputs."` preserved

---

### Module: MOD-013 (parameterize_hardcoded_tables)

**Parent Architecture Modules**: ARCH-008
**Target Source File(s)**: `scripts/bash/refactor/clean-hardcoded-commands.sh`

#### Test Case: UTP-013-A (Branch Coverage — parameterize_hardcoded_tables)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises table header detection, ASIL/DAL/SIL value replacement in table rows, separator row skipping, governing standard parameterization, and no-table path.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (read_lines, write_file) | OS | Temp file with controlled tables | Isolate from real commands |

* **Unit Scenario: UTS-013-A1** (table with ASIL column header and values)
  * **Arrange**: Create file with `| Component | ASIL Level | Notes |` header, separator row, and rows containing `ASIL-B` and `ASIL-D`
  * **Act**: Call `parameterize_hardcoded_tables(command_path)`
  * **Assert**: Header reads `Severity Level`; row values read `Level [domain-specific]`; `tables_modified` equals 1

* **Unit Scenario: UTS-013-A2** (table with DAL values)
  * **Arrange**: Create file with table containing `DAL-A` through `DAL-E` values
  * **Act**: Call `parameterize_hardcoded_tables(command_path)`
  * **Assert**: All DAL values replaced with `Level [domain-specific]`; `tables_modified` equals 1

* **Unit Scenario: UTS-013-A3** (governing standard line parameterized)
  * **Arrange**: Create file with `"Governing standard: ISO 26262"`
  * **Act**: Call `parameterize_hardcoded_tables(command_path)`
  * **Assert**: Line reads `"Governing standard: [per domain configuration]"`

* **Unit Scenario: UTS-013-A4** (no tables found — zero modifications)
  * **Arrange**: Create file with no Markdown tables
  * **Act**: Call `parameterize_hardcoded_tables(command_path)`
  * **Assert**: `tables_modified` equals 0; file content unchanged

#### Test Case: UTP-013-B (BVA — tables_modified count)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests boundary of `tables_modified` counter.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp file with controlled tables | Boundary testing |

* **Unit Scenario: UTS-013-B1** (min: 0 tables)
  * **Arrange**: Create file with no tables
  * **Act**: Call `parameterize_hardcoded_tables(command_path)`
  * **Assert**: `tables_modified` equals 0

* **Unit Scenario: UTS-013-B2** (min+1: 1 table)
  * **Arrange**: Create file with one ASIL table
  * **Act**: Call `parameterize_hardcoded_tables(command_path)`
  * **Assert**: `tables_modified` equals 1

* **Unit Scenario: UTS-013-B3** (mid: 3 tables)
  * **Arrange**: Create file with 3 separate tables (ASIL, DAL, SIL headers)
  * **Act**: Call `parameterize_hardcoded_tables(command_path)`
  * **Assert**: `tables_modified` equals 3


---

### Module: MOD-014 (compose_loading_instruction_block)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/refactor/inject-loading-instruction.sh`

#### Test Case: UTP-014-A (Branch Coverage — compose_loading_instruction_block)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises the pure string composition function — valid command_name input and empty command_name edge case.

**Dependency & Mock Registry:**

None — module is self-contained

* **Unit Scenario: UTS-014-A1** (valid command_name — standard composition)
  * **Arrange**: Set `command_name` to `"system-design"`
  * **Act**: Call `compose_loading_instruction_block("system-design")`
  * **Assert**: Returned string starts with `"### Domain Overlay Loading"`; contains `commands/overlays/{domain}/system-design.md`; contains 4 numbered steps

* **Unit Scenario: UTS-014-A2** (different command_name — substitution verified)
  * **Arrange**: Set `command_name` to `"hazard-analysis"`
  * **Act**: Call `compose_loading_instruction_block("hazard-analysis")`
  * **Assert**: Contains `commands/overlays/{domain}/hazard-analysis.md`; overall structure identical to UTS-014-A1

* **Unit Scenario: UTS-014-A3** (empty command_name)
  * **Arrange**: Set `command_name` to `""`
  * **Act**: Call `compose_loading_instruction_block("")`
  * **Assert**: Returns empty string (per error handling contract)

---

### Module: MOD-015 (inject_loading_instruction)

**Parent Architecture Modules**: ARCH-009
**Target Source File(s)**: `scripts/bash/refactor/inject-loading-instruction.sh`

#### Test Case: UTP-015-A (Branch Coverage — inject_loading_instruction)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises duplicate detection skip, ad-hoc pattern removal, injection point at `## Operating Constraints`, injection at EOF when no marker found, and file write.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| MOD-014 (compose_loading_instruction_block) | Sibling function | Stub returning fixed block text | Isolate composition logic |
| Filesystem (read_file, write_file) | OS | Temp file with controlled content | Deterministic injection |

* **Unit Scenario: UTS-015-A1** (no existing block, Operating Constraints marker present)
  * **Arrange**: Create command file with `## Operating Constraints` at line 40; no domain loading block; stub MOD-014 to return 7-line block
  * **Act**: Call `inject_loading_instruction(command_path)`
  * **Assert**: Exit code 0; `injected` is `true`; block inserted before line 40; file grows by 7 lines

* **Unit Scenario: UTS-015-A2** (duplicate block present — idempotent skip)
  * **Arrange**: Create command file already containing `### Domain Overlay Loading`
  * **Act**: Call `inject_loading_instruction(command_path)`
  * **Assert**: Exit code 0; stdout contains `duplicate_injection`; file unchanged

* **Unit Scenario: UTS-015-A3** (ad-hoc conditional patterns removed)
  * **Arrange**: Create command file with `If domain is set, include overlay content` and `When domain is configured, append sections`
  * **Act**: Call `inject_loading_instruction(command_path)`
  * **Assert**: `ad_hoc_patterns_found` equals 2; neither pattern remains in file; standard block injected

* **Unit Scenario: UTS-015-A4** (no Operating Constraints marker — append at EOF)
  * **Arrange**: Create command file with no `## Operating Constraints` heading
  * **Act**: Call `inject_loading_instruction(command_path)`
  * **Assert**: Exit code 0; block appended at end of file

#### Test Case: UTP-015-B (Equivalence Partitioning — duplicate detection boolean)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions the duplicate detection check (`content contains "### Domain Overlay Loading"`) into present/absent.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| MOD-014 | Sibling function | Stub | Isolate composition |

* **Unit Scenario: UTS-015-B1** (partition: block absent — injection proceeds)
  * **Arrange**: Create file with no `### Domain Overlay Loading` heading
  * **Act**: Call `inject_loading_instruction(command_path)`
  * **Assert**: `injected` is `true`; file modified

* **Unit Scenario: UTS-015-B2** (partition: block present — skip)
  * **Arrange**: Create file containing `### Domain Overlay Loading` heading
  * **Act**: Call `inject_loading_instruction(command_path)`
  * **Assert**: `injected` is not set; file unchanged

#### Test Case: UTP-015-C (Strict Isolation — MOD-014 dependency)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-014 is properly stubbed and its output is used verbatim for injection.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| MOD-014 (compose_loading_instruction_block) | ARCH-009 | Function stub returning fixed string with call counter | Verify single invocation |

* **Unit Scenario: UTS-015-C1** (MOD-014 stub invoked exactly once with correct command_name)
  * **Arrange**: Set up call-tracking stub for MOD-014; command file is `system-test.md`
  * **Act**: Call `inject_loading_instruction(command_path)`
  * **Assert**: MOD-014 called once with argument `"system-test"`; injected text matches stub output exactly

---

### Module: MOD-016 (parse_gate_boundaries)

**Parent Architecture Modules**: ARCH-010
**Target Source File(s)**: `scripts/bash/refactor/parse-template-gates.sh`

#### Test Case: UTP-016-A (Branch Coverage — parse_gate_boundaries)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises file existence check, opening gate detection, closing gate matching, malformed gate error (unmatched close), unclosed gate error, nested gates, and no-gates-found path.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (file_exists, read_lines) | OS | Temp file with controlled gate comments | Deterministic gate parsing |

* **Unit Scenario: UTS-016-A1** (single matched gate pair)
  * **Arrange**: Create template with `<!-- SAFETY-CRITICAL SECTION -->` at line 10, domain content, `<!-- END SAFETY-CRITICAL SECTION -->` at line 20
  * **Act**: Call `parse_gate_boundaries(template_path)`
  * **Assert**: Exit code 0; `gate_blocks` array length equals 1; block has `gate_type: "SAFETY-CRITICAL"`, `start_line: 11`, `end_line: 20`

* **Unit Scenario: UTS-016-A2** (multiple gate types in same template)
  * **Arrange**: Create template with SAFETY-CRITICAL gate at lines 10-20 and SAFETY-TECHNIQUES gate at lines 30-40
  * **Act**: Call `parse_gate_boundaries(template_path)`
  * **Assert**: `gate_blocks` length equals 2; each block has correct `gate_type`

* **Unit Scenario: UTS-016-A3** (unmatched closing gate — error)
  * **Arrange**: Create template with `<!-- END SAFETY-CRITICAL SECTION -->` at line 15 but no matching open
  * **Act**: Call `parse_gate_boundaries(template_path)`
  * **Assert**: Exit code 1; stderr contains `malformed_gate`

* **Unit Scenario: UTS-016-A4** (unclosed opening gate — error)
  * **Arrange**: Create template with `<!-- SAFETY-CRITICAL SECTION -->` at line 10 but no closing gate
  * **Act**: Call `parse_gate_boundaries(template_path)`
  * **Assert**: Exit code 1; stderr contains `malformed_gate`

* **Unit Scenario: UTS-016-A5** (no gates found — clean template)
  * **Arrange**: Create template with no gate comments
  * **Act**: Call `parse_gate_boundaries(template_path)`
  * **Assert**: Exit code 0; `gate_blocks` is empty array

* **Unit Scenario: UTS-016-A6** (file not found)
  * **Arrange**: Set `template_path` to nonexistent path
  * **Act**: Call `parse_gate_boundaries(template_path)`
  * **Assert**: Exit code 1; stderr contains `file_not_found`

#### Test Case: UTP-016-B (BVA — nesting depth)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests the `open_stack` nesting depth boundary — 0 (no gates), 1 (flat), 2 (nested).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp file with controlled nesting | Boundary testing |

* **Unit Scenario: UTS-016-B1** (depth 0 — no gates on stack)
  * **Arrange**: Create template with no gate comments
  * **Act**: Call `parse_gate_boundaries(template_path)`
  * **Assert**: `gate_blocks` empty; stack never pushed

* **Unit Scenario: UTS-016-B2** (depth 1 — single non-nested gate)
  * **Arrange**: Create template with one SAFETY-CRITICAL gate pair
  * **Act**: Call `parse_gate_boundaries(template_path)`
  * **Assert**: Stack pushed once, popped once; 1 block returned

* **Unit Scenario: UTS-016-B3** (depth 2 — nested gate within gate)
  * **Arrange**: Create template with SAFETY-CRITICAL gate containing a DOMAIN-SCALES gate inside it
  * **Act**: Call `parse_gate_boundaries(template_path)`
  * **Assert**: Stack reaches depth 2; inner gate popped first; 2 blocks returned with correct nesting

#### Test Case: UTP-016-C (Equivalence Partitioning — gate_type enum)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions the `gate_type` enum into its 3 valid values.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp file with controlled gate types | Partition testing |

* **Unit Scenario: UTS-016-C1** (partition: SAFETY-CRITICAL)
  * **Arrange**: Create template with `<!-- SAFETY-CRITICAL SECTION -->` and matching close
  * **Act**: Call `parse_gate_boundaries(template_path)`
  * **Assert**: Block `gate_type` equals `"SAFETY-CRITICAL"`

* **Unit Scenario: UTS-016-C2** (partition: DOMAIN-SCALES)
  * **Arrange**: Create template with `<!-- DOMAIN-SPECIFIC SCALES -->` and matching close
  * **Act**: Call `parse_gate_boundaries(template_path)`
  * **Assert**: Block `gate_type` equals `"DOMAIN-SCALES"`

* **Unit Scenario: UTS-016-C3** (partition: SAFETY-TECHNIQUES)
  * **Arrange**: Create template with `<!-- SAFETY-CRITICAL TECHNIQUES -->` and matching close
  * **Act**: Call `parse_gate_boundaries(template_path)`
  * **Assert**: Block `gate_type` equals `"SAFETY-TECHNIQUES"`

---

### Module: MOD-017 (extract_gated_content)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `scripts/bash/refactor/extract-template-content.sh`

#### Test Case: UTP-017-A (Branch Coverage — extract_gated_content)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises empty gate_blocks error, target directory validation, content concatenation per domain, and overlay file creation.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (directory_exists, write_file) | OS | Temp directory structure | Isolate writes |

* **Unit Scenario: UTS-017-A1** (valid extraction — two gates, three domains)
  * **Arrange**: Set `gate_blocks` to 2 entries with content; `target_domains` = `["iso_26262", "do_178c", "iec_62304"]`; create all target directories
  * **Act**: Call `extract_gated_content(template_path, gate_blocks, target_domains, overlay_base)`
  * **Assert**: 3 overlay files created (one per domain); each contains both gate block contents; `count` equals 3

* **Unit Scenario: UTS-017-A2** (empty gate_blocks — error)
  * **Arrange**: Set `gate_blocks` to empty list
  * **Act**: Call `extract_gated_content(template_path, [], target_domains, overlay_base)`
  * **Assert**: Exit code 1; stderr contains `No gate blocks to extract`

* **Unit Scenario: UTS-017-A3** (target directory missing — error)
  * **Arrange**: Set `gate_blocks` to 1 entry; `target_domains` = `["iso_26262"]`; do NOT create `templates/overlays/iso_26262/`
  * **Act**: Call `extract_gated_content(template_path, gate_blocks, target_domains, overlay_base)`
  * **Assert**: Exit code 1; stderr contains `target_dir_missing`

#### Test Case: UTP-017-B (BVA — gate_blocks count)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests boundary of `gate_blocks` list size (≥1 required for success, 0 = error).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp directory | Boundary testing |

* **Unit Scenario: UTS-017-B1** (min-1: 0 blocks — error)
  * **Arrange**: Empty `gate_blocks` list
  * **Act**: Call `extract_gated_content(template_path, [], domains, base)`
  * **Assert**: Exit code 1

* **Unit Scenario: UTS-017-B2** (min: 1 block)
  * **Arrange**: Single gate block with content
  * **Act**: Call `extract_gated_content(template_path, [block], domains, base)`
  * **Assert**: Exit code 0; overlay files contain single section

* **Unit Scenario: UTS-017-B3** (mid: 3 blocks — all three gate types)
  * **Arrange**: Three gate blocks (SAFETY-CRITICAL, DOMAIN-SCALES, SAFETY-TECHNIQUES)
  * **Act**: Call `extract_gated_content(template_path, blocks, domains, base)`
  * **Assert**: Each overlay file contains 3 sections concatenated

---

### Module: MOD-018 (clean_base_template)

**Parent Architecture Modules**: ARCH-011
**Target Source File(s)**: `scripts/bash/refactor/extract-template-content.sh`

#### Test Case: UTP-018-A (Branch Coverage — clean_base_template)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises range construction from gate_blocks, overlapping range merge, reverse-order removal, zero-remaining-gates verification pass, and incomplete cleaning error.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (read_lines, write_file) | OS | Temp template file with controlled gates | Isolate from real templates |

* **Unit Scenario: UTS-018-A1** (single gate block — clean removal)
  * **Arrange**: Create 50-line template; gate block from line 20-30 (includes open/close comments)
  * **Act**: Call `clean_base_template(template_path, gate_blocks)`
  * **Assert**: Exit code 0; `lines_removed` equals 11; `remaining_gates` equals 0; file has 39 lines

* **Unit Scenario: UTS-018-A2** (overlapping ranges merged)
  * **Arrange**: Create template with gate block A (lines 10-20) and gate block B (lines 18-25) — overlapping
  * **Act**: Call `clean_base_template(template_path, gate_blocks)`
  * **Assert**: Merged range covers lines 10-25; `lines_removed` equals 16

* **Unit Scenario: UTS-018-A3** (gate patterns remain after cleaning — error)
  * **Arrange**: Create template where removing gate_blocks still leaves an orphan `<!-- SAFETY-CRITICAL` comment not in gate_blocks
  * **Act**: Call `clean_base_template(template_path, gate_blocks)`
  * **Assert**: Exit code 1; stderr contains `Cleaning incomplete`; `remaining_gates` > 0

* **Unit Scenario: UTS-018-A4** (multiple non-overlapping gates — all removed)
  * **Arrange**: Create template with 3 gate blocks at lines 10-15, 25-30, 40-45
  * **Act**: Call `clean_base_template(template_path, gate_blocks)`
  * **Assert**: All 3 blocks removed; `lines_removed` equals 18; `remaining_gates` equals 0

#### Test Case: UTP-018-B (BVA — remaining_gates count)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests the critical boundary `remaining_gates` must be 0 for success.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp template file | Boundary testing |

* **Unit Scenario: UTS-018-B1** (remaining_gates = 0 — success)
  * **Arrange**: Create template where gate_blocks covers all gate comments
  * **Act**: Call `clean_base_template(template_path, gate_blocks)`
  * **Assert**: Exit code 0; `remaining_gates` equals 0

* **Unit Scenario: UTS-018-B2** (remaining_gates = 1 — failure)
  * **Arrange**: Create template with 2 gate pairs; gate_blocks covers only 1; 1 orphan gate remains
  * **Act**: Call `clean_base_template(template_path, gate_blocks)`
  * **Assert**: Exit code 1; `remaining_gates` equals 1

---

### Module: MOD-019 (populate_iso26262_command_overlays)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `scripts/bash/populate/populate-iso26262.sh`

#### Test Case: UTP-019-A (Branch Coverage — populate_iso26262_command_overlays)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises target directory validation, extracted content present/absent per command, minimum file count threshold, and placeholder generation.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (directory_exists, write_file) | OS | Temp overlay directory | Isolate file creation |

* **Unit Scenario: UTS-019-A1** (all 9 commands with extracted content)
  * **Arrange**: Create `commands/overlays/iso_26262/` directory; populate `extracted_content` with entries for all 9 REQUIRED_COMMANDS
  * **Act**: Call `populate_iso26262_command_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 0; `file_count` equals 9; each file contains `## Domain-Specific Extensions` with extracted content

* **Unit Scenario: UTS-019-A2** (some commands without extracted content — placeholders)
  * **Arrange**: Provide extracted content for 5 of 9 commands; remaining 4 have empty content
  * **Act**: Call `populate_iso26262_command_overlays(extracted_content, repo_root)`
  * **Assert**: 9 files created; 4 files contain `<!-- Placeholder:` comment; `file_count` equals 9

* **Unit Scenario: UTS-019-A3** (target directory missing — error)
  * **Arrange**: Do NOT create `commands/overlays/iso_26262/`
  * **Act**: Call `populate_iso26262_command_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 1; stderr contains `target_dir_missing`

#### Test Case: UTP-019-B (BVA — files_created threshold)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests the minimum threshold of 9 overlays for ISO 26262 command population.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp directory | Boundary testing |

* **Unit Scenario: UTS-019-B1** (min-1: 8 files — threshold violation — not reachable with fixed REQUIRED_COMMANDS of 9)
  * **Arrange**: N/A — loop always processes all 9 REQUIRED_COMMANDS; failure only on write error
  * **Act**: N/A
  * **Assert**: Boundary cannot be reached unless write failure occurs

* **Unit Scenario: UTS-019-B2** (min: 9 files — exact threshold)
  * **Arrange**: Create target directory; provide extracted content for all 9 commands
  * **Act**: Call `populate_iso26262_command_overlays(extracted_content, repo_root)`
  * **Assert**: `file_count` equals 9; exit code 0

* **Unit Scenario: UTS-019-B3** (write failure after 8 files — below threshold)
  * **Arrange**: Create target directory; make 9th file path read-only to force write failure
  * **Act**: Call `populate_iso26262_command_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 1; stderr contains `content_missing`

---

### Module: MOD-020 (populate_iso26262_template_overlays)

**Parent Architecture Modules**: ARCH-012
**Target Source File(s)**: `scripts/bash/populate/populate-iso26262.sh`

#### Test Case: UTP-020-A (Branch Coverage — populate_iso26262_template_overlays)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises target directory validation, non-empty content writing, empty content skipping, and zero-file output.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (directory_exists, write_file) | OS | Temp overlay directory | Isolate file creation |

* **Unit Scenario: UTS-020-A1** (extracted content for 3 templates)
  * **Arrange**: Create `templates/overlays/iso_26262/`; `extracted_content` has 3 non-empty entries
  * **Act**: Call `populate_iso26262_template_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 0; `file_count` equals 3; files named `{template_name}-overlay.md`

* **Unit Scenario: UTS-020-A2** (empty extracted content — no files created)
  * **Arrange**: Create target directory; `extracted_content` has only empty values
  * **Act**: Call `populate_iso26262_template_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 0; `file_count` equals 0

* **Unit Scenario: UTS-020-A3** (target directory missing)
  * **Arrange**: Do NOT create target directory
  * **Act**: Call `populate_iso26262_template_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 1; stderr contains `target_dir_missing`


---

### Module: MOD-021 (populate_do178c_command_overlays)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `scripts/bash/populate/populate-do178c.sh`

#### Test Case: UTP-021-A (Branch Coverage — populate_do178c_command_overlays)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises target directory validation, DAL classification system injection, extracted content present/absent, and minimum file count threshold of 6.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (directory_exists, write_file) | OS | Temp overlay directory | Isolate file creation |

* **Unit Scenario: UTS-021-A1** (all 6 commands with extracted content)
  * **Arrange**: Create `commands/overlays/do_178c/`; provide extracted content for all 6 REQUIRED_COMMANDS
  * **Act**: Call `populate_do178c_command_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 0; `file_count` equals 6; each file header contains `DO-178C Domain Overlay` and `DAL (Design Assurance Level)`

* **Unit Scenario: UTS-021-A2** (partial extracted content — placeholders for missing)
  * **Arrange**: Provide content for 3 of 6 commands
  * **Act**: Call `populate_do178c_command_overlays(extracted_content, repo_root)`
  * **Assert**: 6 files created; 3 contain placeholder comments; `file_count` equals 6

* **Unit Scenario: UTS-021-A3** (target directory missing)
  * **Arrange**: Do NOT create `commands/overlays/do_178c/`
  * **Act**: Call `populate_do178c_command_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 1; stderr contains `target_dir_missing`

#### Test Case: UTP-021-B (BVA — files_created threshold of 6)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests the minimum threshold of 6 overlays for DO-178C command population.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp directory | Boundary testing |

* **Unit Scenario: UTS-021-B1** (min: 6 files — exact threshold)
  * **Arrange**: Create target directory; all 6 REQUIRED_COMMANDS processed
  * **Act**: Call `populate_do178c_command_overlays(extracted_content, repo_root)`
  * **Assert**: `file_count` equals 6; exit code 0

* **Unit Scenario: UTS-021-B2** (below threshold: write failure after 5 files)
  * **Arrange**: Create target directory; make 6th file path read-only
  * **Act**: Call `populate_do178c_command_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 1; stderr contains `content_missing`

---

### Module: MOD-022 (populate_do178c_template_overlays)

**Parent Architecture Modules**: ARCH-013
**Target Source File(s)**: `scripts/bash/populate/populate-do178c.sh`

#### Test Case: UTP-022-A (Branch Coverage — populate_do178c_template_overlays)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises target directory validation, non-empty content writing, empty content skipping. Structure mirrors MOD-020 for template overlay population.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (directory_exists, write_file) | OS | Temp overlay directory | Isolate file creation |

* **Unit Scenario: UTS-022-A1** (extracted content for 2 templates)
  * **Arrange**: Create `templates/overlays/do_178c/`; provide 2 non-empty template content entries
  * **Act**: Call `populate_do178c_template_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 0; `file_count` equals 2; files named `{template_name}-overlay.md`

* **Unit Scenario: UTS-022-A2** (no extracted content — zero files)
  * **Arrange**: Create target directory; `extracted_content` is empty map
  * **Act**: Call `populate_do178c_template_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 0; `file_count` equals 0

* **Unit Scenario: UTS-022-A3** (target directory missing)
  * **Arrange**: Do NOT create target directory
  * **Act**: Call `populate_do178c_template_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 1; stderr contains `target_dir_missing`

---

### Module: MOD-023 (populate_iec62304_command_overlays)

**Parent Architecture Modules**: ARCH-014
**Target Source File(s)**: `scripts/bash/populate/populate-iec62304.sh`

#### Test Case: UTP-023-A (Branch Coverage — populate_iec62304_command_overlays)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises target directory validation, Safety Class classification injection, extracted content present/absent, and minimum file count threshold of 3.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (directory_exists, write_file) | OS | Temp overlay directory | Isolate file creation |

* **Unit Scenario: UTS-023-A1** (all 3 commands with extracted content)
  * **Arrange**: Create `commands/overlays/iec_62304/`; provide extracted content for `hazard-analysis`, `trace`, `peer-review`
  * **Act**: Call `populate_iec62304_command_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 0; `file_count` equals 3; each file contains `Safety Class A, B, or C`

* **Unit Scenario: UTS-023-A2** (partial content — placeholder for missing)
  * **Arrange**: Provide content for 1 of 3 commands
  * **Act**: Call `populate_iec62304_command_overlays(extracted_content, repo_root)`
  * **Assert**: 3 files created; 2 contain placeholder comments; `file_count` equals 3

* **Unit Scenario: UTS-023-A3** (target directory missing)
  * **Arrange**: Do NOT create target directory
  * **Act**: Call `populate_iec62304_command_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 1; stderr contains `target_dir_missing`

#### Test Case: UTP-023-B (BVA — files_created threshold of 3)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests the minimum threshold of 3 overlays for IEC 62304 command population.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp directory | Boundary testing |

* **Unit Scenario: UTS-023-B1** (min: 3 files — exact threshold)
  * **Arrange**: Create target directory; all 3 REQUIRED_COMMANDS processed
  * **Act**: Call `populate_iec62304_command_overlays(extracted_content, repo_root)`
  * **Assert**: `file_count` equals 3; exit code 0

* **Unit Scenario: UTS-023-B2** (below threshold: write failure after 2 files)
  * **Arrange**: Create target directory; make 3rd file path read-only
  * **Act**: Call `populate_iec62304_command_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 1; stderr contains `content_missing`

---

### Module: MOD-024 (populate_iec62304_template_overlays)

**Parent Architecture Modules**: ARCH-014
**Target Source File(s)**: `scripts/bash/populate/populate-iec62304.sh`

#### Test Case: UTP-024-A (Branch Coverage — populate_iec62304_template_overlays)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises target directory validation, non-empty content writing, empty content skipping. Structure mirrors MOD-020 and MOD-022.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (directory_exists, write_file) | OS | Temp overlay directory | Isolate file creation |

* **Unit Scenario: UTS-024-A1** (extracted content for 1 template)
  * **Arrange**: Create `templates/overlays/iec_62304/`; provide 1 non-empty template content entry
  * **Act**: Call `populate_iec62304_template_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 0; `file_count` equals 1

* **Unit Scenario: UTS-024-A2** (no extracted content — zero files)
  * **Arrange**: Create target directory; empty `extracted_content` map
  * **Act**: Call `populate_iec62304_template_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 0; `file_count` equals 0

* **Unit Scenario: UTS-024-A3** (target directory missing)
  * **Arrange**: Do NOT create target directory
  * **Act**: Call `populate_iec62304_template_overlays(extracted_content, repo_root)`
  * **Assert**: Exit code 1; stderr contains `target_dir_missing`

---

### Module: MOD-025 (rewrite_extension_descriptions)

**Parent Architecture Modules**: ARCH-015
**Target Source File(s)**: `scripts/bash/metadata/rewrite-extension-desc.sh`

#### Test Case: UTP-025-A (Branch Coverage — rewrite_extension_descriptions)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises file existence check, safety-critical tag pre-check, description field detection, term stripping, whitespace cleanup, post-rewrite tag verification, and warning for partial modifications.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (file_exists, read_file, write_file) | OS | Temp extension.yml file | Isolate from real extension metadata |

* **Unit Scenario: UTS-025-A1** (9 descriptions with domain terms — all cleaned)
  * **Arrange**: Create temp extension.yml with 9 command entries; each `description:` field contains terms from DESCRIPTION_CLEANUP list (e.g., `"per DO-178C"`, `"ASIL compliance"`)
  * **Act**: Call `rewrite_extension_descriptions(extension_path, repo_root)`
  * **Assert**: Exit code 0; `descriptions_changed` equals 9; no domain terms remain in descriptions; `safety-critical` tag preserved

* **Unit Scenario: UTS-025-A2** (file not found)
  * **Arrange**: Set `extension_path` to nonexistent file
  * **Act**: Call `rewrite_extension_descriptions(extension_path, repo_root)`
  * **Assert**: Exit code 1; stderr contains `file_not_found`

* **Unit Scenario: UTS-025-A3** (safety-critical tag missing — pre-check failure)
  * **Arrange**: Create extension.yml without `safety-critical` anywhere in content
  * **Act**: Call `rewrite_extension_descriptions(extension_path, repo_root)`
  * **Assert**: Exit code 1; stderr contains `tag_removed`

* **Unit Scenario: UTS-025-A4** (rewriting accidentally removes safety-critical tag — post-check failure)
  * **Arrange**: Create extension.yml where `safety-critical` only appears inside a description field that gets cleaned, causing the tag to be removed
  * **Act**: Call `rewrite_extension_descriptions(extension_path, repo_root)`
  * **Assert**: Exit code 1; stderr contains `tag_removed`

* **Unit Scenario: UTS-025-A5** (fewer than 9 descriptions modified — warning)
  * **Arrange**: Create extension.yml with 9 commands; 5 already clean (no domain terms); 4 need cleaning
  * **Act**: Call `rewrite_extension_descriptions(extension_path, repo_root)`
  * **Assert**: Exit code 0; `descriptions_changed` equals 4; warning printed about `only 4/9 descriptions modified`

#### Test Case: UTP-025-B (BVA — descriptions_changed expected count)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests the `descriptions_changed` counter boundary — expected value is 9, warning below 9.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp extension.yml | Boundary testing |

* **Unit Scenario: UTS-025-B1** (0 descriptions changed — all already clean)
  * **Arrange**: Create extension.yml with 9 clean descriptions (no domain terms)
  * **Act**: Call `rewrite_extension_descriptions(extension_path, repo_root)`
  * **Assert**: `descriptions_changed` equals 0; warning printed

* **Unit Scenario: UTS-025-B2** (8 descriptions changed — below expected)
  * **Arrange**: 8 of 9 descriptions contain domain terms; 1 already clean
  * **Act**: Call `rewrite_extension_descriptions(extension_path, repo_root)`
  * **Assert**: `descriptions_changed` equals 8; warning printed

* **Unit Scenario: UTS-025-B3** (9 descriptions changed — exact expected)
  * **Arrange**: All 9 descriptions contain domain terms
  * **Act**: Call `rewrite_extension_descriptions(extension_path, repo_root)`
  * **Assert**: `descriptions_changed` equals 9; no warning

#### Test Case: UTP-025-C (Strict Isolation — YAML line parsing)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies extension.yml is parsed via line-by-line regex (not yq), isolating the description detection from YAML structural complexities.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (read_file, write_file) | OS | Temp extension.yml with known structure | Verify regex-based parsing |

* **Unit Scenario: UTS-025-C1** (description field on indented line detected correctly)
  * **Arrange**: Create extension.yml with `    description: Generate per DO-178C compliance` (4-space indent)
  * **Act**: Call `rewrite_extension_descriptions(extension_path, repo_root)`
  * **Assert**: `descriptions_changed` ≥1; regex `^\s+description:\s+` matched correctly

* **Unit Scenario: UTS-025-C2** (non-description field with similar pattern not matched)
  * **Arrange**: Create extension.yml with `name: description-based-tool` (contains "description" but not as a field)
  * **Act**: Call `rewrite_extension_descriptions(extension_path, repo_root)`
  * **Assert**: `name` field unchanged; regex does not match top-level `name:` line

---

### Module: MOD-026 (map_commands_to_features)

**Parent Architecture Modules**: ARCH-016
**Target Source File(s)**: `scripts/bash/lifecycle/map-parent-features.sh`

#### Test Case: UTP-026-A (Branch Coverage — map_commands_to_features)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises command lookup in COMMAND_FEATURE_MAP, unmapped command error, feature directory existence/fallback, and artifact path collection.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (directory_exists, list_directory) | OS | Temp specs/ directory with controlled feature dirs | Isolate from real specs |

* **Unit Scenario: UTS-026-A1** (all 9 mapped commands — full mapping)
  * **Arrange**: Create specs/ directory with feature dirs for 001, 002, 003, 004, 005a, 005c; provide all 9 command names
  * **Act**: Call `map_commands_to_features(command_names)`
  * **Assert**: Exit code 0; `mapping_table` has 9 entries; each has correct `feature_id` and `artifact_paths`

* **Unit Scenario: UTS-026-A2** (unmapped command — error)
  * **Arrange**: Include `"unknown-command"` in `command_names` list
  * **Act**: Call `map_commands_to_features(command_names)`
  * **Assert**: Exit code 1; stderr contains `unmapped_command: unknown-command`

* **Unit Scenario: UTS-026-A3** (feature directory not found — fallback path)
  * **Arrange**: Provide `["trace"]` (maps to feature 001); do NOT create `specs/001-*` directory
  * **Act**: Call `map_commands_to_features(["trace"])`
  * **Assert**: Exit code 0; `artifact_paths` is empty (directory doesn't exist); fallback path `specs/001` used

* **Unit Scenario: UTS-026-A4** (feature directory with v-model artifacts)
  * **Arrange**: Create `specs/002-system-design/v-model/` with `requirements.md` and `system-design.md`; provide `["system-design"]`
  * **Act**: Call `map_commands_to_features(["system-design"])`
  * **Assert**: `artifact_paths` contains 2 paths; `feature_id` equals `"002"`

#### Test Case: UTP-026-B (Equivalence Partitioning — command mapping validity)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions `command_names` into valid (in COMMAND_FEATURE_MAP) and invalid (not in map) classes.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp specs/ directory | Partition testing |

* **Unit Scenario: UTS-026-B1** (valid partition: all 9 known commands)
  * **Arrange**: Provide all 9 commands from COMMAND_FEATURE_MAP
  * **Act**: Call `map_commands_to_features(command_names)`
  * **Assert**: All 9 mapped successfully; exit code 0

* **Unit Scenario: UTS-026-B2** (invalid partition: command not in map)
  * **Arrange**: Provide `["requirements"]` (not in map — CLEAN command, not refactored)
  * **Act**: Call `map_commands_to_features(["requirements"])`
  * **Assert**: Exit code 1; `unmapped_command` error


---

### Module: MOD-027 (locate_artifact_ids)

**Parent Architecture Modules**: ARCH-017
**Target Source File(s)**: `scripts/bash/lifecycle/annotate-modified.sh`

#### Test Case: UTP-027-A (Branch Coverage — locate_artifact_ids)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises file not found (empty return), line-by-line scanning, regex match extraction, already-annotated skip, and multi-match-per-line accumulation.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem (file_exists, read_lines) | OS | Temp artifact file with controlled IDs | Isolate from real artifacts |

* **Unit Scenario: UTS-027-A1** (file with 3 IDs across 2 lines)
  * **Arrange**: Create artifact with line 1: `"### REQ-001 — Overlay directory"`, line 2: `"Traces: REQ-002, REQ-003"`
  * **Act**: Call `locate_artifact_ids(artifact_path, "REQ-")`
  * **Assert**: Returns list of 3 objects; each has `id`, `line_number`, `artifact_path`, `line_content`

* **Unit Scenario: UTS-027-A2** (file not found — empty return)
  * **Arrange**: Set `artifact_path` to nonexistent file
  * **Act**: Call `locate_artifact_ids(artifact_path, "SYS-")`
  * **Assert**: Returns empty list

* **Unit Scenario: UTS-027-A3** (IDs already annotated — skipped)
  * **Arrange**: Create artifact with `"REQ-001 [MODIFIED — content extracted]"`
  * **Act**: Call `locate_artifact_ids(artifact_path, "REQ-")`
  * **Assert**: Returns empty list (line contains `[MODIFIED` so ID is skipped)

* **Unit Scenario: UTS-027-A4** (IDs with DEPRECATED annotation — also skipped)
  * **Arrange**: Create artifact with `"REQ-005 [DEPRECATED — Withdrawn]"`
  * **Act**: Call `locate_artifact_ids(artifact_path, "REQ-")`
  * **Assert**: Returns empty list

* **Unit Scenario: UTS-027-A5** (no matching IDs — wrong pattern)
  * **Arrange**: Create artifact with `"### SYS-001"` lines; search with `"ARCH-"` pattern
  * **Act**: Call `locate_artifact_ids(artifact_path, "ARCH-")`
  * **Assert**: Returns empty list

#### Test Case: UTP-027-B (BVA — located_ids count)

**Technique**: Boundary Value Analysis
**Target View**: Internal Data Structures
**Description**: Tests boundary of `located_ids` list size (0 = no matches, unbounded max).

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| Filesystem | OS | Temp artifact files | Boundary testing |

* **Unit Scenario: UTS-027-B1** (min: 0 IDs found)
  * **Arrange**: Create artifact with no matching ID patterns
  * **Act**: Call `locate_artifact_ids(artifact_path, "MOD-")`
  * **Assert**: Returns empty list; length equals 0

* **Unit Scenario: UTS-027-B2** (min+1: 1 ID found)
  * **Arrange**: Create artifact with single `MOD-001` reference
  * **Act**: Call `locate_artifact_ids(artifact_path, "MOD-")`
  * **Assert**: Returns list of length 1

* **Unit Scenario: UTS-027-B3** (mid: 10 IDs across multiple lines)
  * **Arrange**: Create artifact with 10 distinct MOD references
  * **Act**: Call `locate_artifact_ids(artifact_path, "MOD-")`
  * **Assert**: Returns list of length 10; all `line_number` values correct

---

### Module: MOD-028 (write_modified_annotations)

**Parent Architecture Modules**: ARCH-017
**Target Source File(s)**: `scripts/bash/lifecycle/annotate-modified.sh`

#### Test Case: UTP-028-A (Branch Coverage — write_modified_annotations)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises 006b availability check, contamination_type validation, annotation template selection, MOD-027 delegation, annotation writing, and already-annotated skip.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| MOD-027 (locate_artifact_ids) | Sibling function | Stub returning controlled ID locations | Isolate from real artifact scanning |
| check_006b_availability | Helper function | Stub returning controlled boolean | Isolate from 006b status |
| Filesystem (read_lines, write_file) | OS | Temp artifact files | Isolate annotation writes |

* **Unit Scenario: UTS-028-A1** (MIXED contamination — annotations written)
  * **Arrange**: Stub `check_006b_availability` to return true; stub MOD-027 to return 2 located IDs; create temp artifact files; `contamination_type` = `"MIXED"`
  * **Act**: Call `write_modified_annotations(mapping_table, "MIXED")`
  * **Assert**: Exit code 0; `annotations_written` equals 2; each annotated line contains `[MODIFIED — Domain-specific content extracted to overlay per Feature 006a]`

* **Unit Scenario: UTS-028-A2** (HARDCODED contamination — different annotation text)
  * **Arrange**: Same as A1 but `contamination_type` = `"HARDCODED"`
  * **Act**: Call `write_modified_annotations(mapping_table, "HARDCODED")`
  * **Assert**: Annotated lines contain `[MODIFIED — Unconditional domain-specific content removed from base and relocated to overlay per Feature 006a]`

* **Unit Scenario: UTS-028-A3** (006b lifecycle unavailable — error)
  * **Arrange**: Stub `check_006b_availability` to return false
  * **Act**: Call `write_modified_annotations(mapping_table, "MIXED")`
  * **Assert**: Exit code 1; stderr contains `lifecycle_unavailable`

* **Unit Scenario: UTS-028-A4** (invalid contamination_type — error)
  * **Arrange**: Stub 006b as available; set `contamination_type` to `"UNKNOWN"`
  * **Act**: Call `write_modified_annotations(mapping_table, "UNKNOWN")`
  * **Assert**: Exit code 1; stderr contains `Invalid contamination type`

* **Unit Scenario: UTS-028-A5** (IDs already annotated — no duplicate annotations)
  * **Arrange**: Stub MOD-027 to return 0 IDs (all already annotated)
  * **Act**: Call `write_modified_annotations(mapping_table, "MIXED")`
  * **Assert**: Exit code 0; `annotations_written` equals 0

#### Test Case: UTP-028-B (Equivalence Partitioning — contamination_type enum)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions `contamination_type` into valid (MIXED, HARDCODED) and invalid classes.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| MOD-027, check_006b | Dependencies | Stubs | Partition isolation |

* **Unit Scenario: UTS-028-B1** (valid: MIXED)
  * **Arrange**: `contamination_type` = `"MIXED"`; stubs return success
  * **Act**: Call `write_modified_annotations(mapping_table, "MIXED")`
  * **Assert**: Annotation template used matches MIXED pattern

* **Unit Scenario: UTS-028-B2** (valid: HARDCODED)
  * **Arrange**: `contamination_type` = `"HARDCODED"`; stubs return success
  * **Act**: Call `write_modified_annotations(mapping_table, "HARDCODED")`
  * **Assert**: Annotation template used matches HARDCODED pattern

* **Unit Scenario: UTS-028-B3** (invalid: arbitrary string)
  * **Arrange**: `contamination_type` = `"CLEAN"`
  * **Act**: Call `write_modified_annotations(mapping_table, "CLEAN")`
  * **Assert**: Exit code 1; annotation never applied

#### Test Case: UTP-028-C (Strict Isolation — MOD-027 and check_006b dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies MOD-027 and check_006b_availability are properly stubbed and invocation counts are correct.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| MOD-027 (locate_artifact_ids) | ARCH-017 | Function stub with call counter | Verify called per artifact per pattern |
| check_006b_availability | Helper | Function stub returning true | Verify called exactly once at start |

* **Unit Scenario: UTS-028-C1** (check_006b called once; MOD-027 called per artifact-pattern pair)
  * **Arrange**: Set up call-tracking stubs; mapping_table has 2 entries with 3 artifact_paths each
  * **Act**: Call `write_modified_annotations(mapping_table, "MIXED")`
  * **Assert**: `check_006b_availability` call count equals 1; MOD-027 call count ≥6 (2 entries × 3 paths × patterns per artifact type)

---

### Module: MOD-029 (traverse_and_mark_suspects)

**Parent Architecture Modules**: ARCH-018
**Target Source File(s)**: `scripts/bash/lifecycle/cascade-suspects.sh`

#### Test Case: UTP-029-A (Branch Coverage — traverse_and_mark_suspects)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises prefix extraction, TRACE_CHAIN lookup, downstream artifact search, SUSPECT annotation writing, cycle detection via visited map, and recursive cascade.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| find_artifacts_referencing | Helper function | Stub returning controlled search results | Isolate from real grep |
| Filesystem (read_lines, write_file) | OS | Temp artifact files | Isolate annotation writes |

* **Unit Scenario: UTS-029-A1** (REQ modified — cascades to SYS and ATP)
  * **Arrange**: Set `modified_ids` to `[{id: "REQ-001"}]`; stub `find_artifacts_referencing` to return matching lines in system-design.md (SYS-001) and acceptance-plan.md (ATP-001)
  * **Act**: Call `traverse_and_mark_suspects(modified_ids)`
  * **Assert**: `suspect_items` contains entries for SYS-001 and ATP-001; both annotated with `[SUSPECT — Parent REQ-001 modified]`

* **Unit Scenario: UTS-029-A2** (SYS modified — cascades to ARCH and STP)
  * **Arrange**: Set `modified_ids` to `[{id: "SYS-002"}]`; stub to find ARCH-003 and STP-005 referencing SYS-002
  * **Act**: Call `traverse_and_mark_suspects(modified_ids)`
  * **Assert**: ARCH-003 and STP-005 marked SUSPECT; recursive cascade continues from ARCH-003 to MOD and ITP

* **Unit Scenario: UTS-029-A3** (MOD modified — cascades only to UTP)
  * **Arrange**: Set `modified_ids` to `[{id: "MOD-010"}]`; stub to find UTP-010-A referencing MOD-010
  * **Act**: Call `traverse_and_mark_suspects(modified_ids)`
  * **Assert**: UTP-010-A marked SUSPECT; no further cascade (UTP has no downstream in TRACE_CHAIN)

* **Unit Scenario: UTS-029-A4** (test ID — no cascade)
  * **Arrange**: Set `modified_ids` to `[{id: "ATP-003"}]`
  * **Act**: Call `traverse_and_mark_suspects(modified_ids)`
  * **Assert**: `suspect_items` is empty; ATP prefix not in TRACE_CHAIN

* **Unit Scenario: UTS-029-A5** (cycle detection — visited map prevents infinite loop)
  * **Arrange**: Set up circular reference: REQ-001 → SYS-001, SYS-001 → ARCH-001, ARCH-001 references REQ-001
  * **Act**: Call `traverse_and_mark_suspects([{id: "REQ-001"}])`
  * **Assert**: Each ID annotated at most once; `visited` map prevents re-processing; function terminates

* **Unit Scenario: UTS-029-A6** (no downstream artifacts found — graceful)
  * **Arrange**: Set `modified_ids` to `[{id: "REQ-005"}]`; stub `find_artifacts_referencing` to return empty results
  * **Act**: Call `traverse_and_mark_suspects(modified_ids)`
  * **Assert**: `suspect_items` is empty; `total` equals 0; exit code 0

#### Test Case: UTP-029-B (Strict Isolation — recursive and find_artifacts dependencies)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies `find_artifacts_referencing` is properly stubbed and recursive calls are tracked.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| find_artifacts_referencing | Helper | Function stub with call tracker and depth counter | Track recursion depth |
| grep_file | OS utility | Stub returning controlled match results | Isolate from real file search |

* **Unit Scenario: UTS-029-B1** (recursion depth tracked — single-level cascade)
  * **Arrange**: Stub `find_artifacts_referencing` to return results at depth 1 only (no further downstream)
  * **Act**: Call `traverse_and_mark_suspects([{id: "REQ-001"}])`
  * **Assert**: `find_artifacts_referencing` called for REQ→SYS and REQ→ATP; no deeper recursion

* **Unit Scenario: UTS-029-B2** (multi-level recursion — REQ→SYS→ARCH→MOD)
  * **Arrange**: Stub to return downstream at each level; 3 levels deep
  * **Act**: Call `traverse_and_mark_suspects([{id: "REQ-001"}])`
  * **Assert**: `find_artifacts_referencing` call count matches expected cascade depth; all levels annotated

---

### Module: MOD-030 (resolve_extractive_suspects)

**Parent Architecture Modules**: ARCH-018
**Target Source File(s)**: `scripts/bash/lifecycle/cascade-suspects.sh`

#### Test Case: UTP-030-A (Branch Coverage — resolve_extractive_suspects)

**Technique**: Statement & Branch Coverage
**Target View**: Algorithmic/Logic View
**Description**: Exercises extractive-only detection, SUSPECT→RESOLVED annotation replacement, non-extractive manual-review path, and resolution summary invariant.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| get_annotation_for_id | Helper function | Stub returning controlled annotation text | Isolate from real artifact search |
| Filesystem (read_lines, write_file) | OS | Temp artifact files with SUSPECT annotations | Isolate resolution writes |

* **Unit Scenario: UTS-030-A1** (extractive-only parent — suspect resolved automatically)
  * **Arrange**: Stub `get_annotation_for_id` to return `"[MODIFIED — Domain-specific content extracted to overlay per Feature 006a]"`; create artifact with `SYS-001 [SUSPECT — Parent REQ-001 modified]`
  * **Act**: Call `resolve_extractive_suspects(suspect_items)`
  * **Assert**: `resolved` equals 1; `requiring_update` equals 0; annotation changed to `[SUSPECT — RESOLVED: extractive-only change, confirmed still valid per Feature 006a]`

* **Unit Scenario: UTS-030-A2** (non-extractive parent — manual review required)
  * **Arrange**: Stub `get_annotation_for_id` to return `"[MODIFIED — Functional behavior changed]"`
  * **Act**: Call `resolve_extractive_suspects(suspect_items)`
  * **Assert**: `resolved` equals 0; `requiring_update` equals 1; SUSPECT annotation unchanged

* **Unit Scenario: UTS-030-A3** (mixed batch — some extractive, some not)
  * **Arrange**: 3 suspect items: 2 with extractive parents, 1 with non-extractive parent
  * **Act**: Call `resolve_extractive_suspects(suspect_items)`
  * **Assert**: `resolved` equals 2; `requiring_update` equals 1; `total` equals 3; invariant `resolved + requiring_update == total` holds

* **Unit Scenario: UTS-030-A4** (parent annotation not found — conservative path)
  * **Arrange**: Stub `get_annotation_for_id` to return empty string
  * **Act**: Call `resolve_extractive_suspects(suspect_items)`
  * **Assert**: `requiring_update` incremented; suspect not auto-resolved

* **Unit Scenario: UTS-030-A5** (empty suspect list — zero processing)
  * **Arrange**: Set `suspect_items` to empty list
  * **Act**: Call `resolve_extractive_suspects([])`
  * **Assert**: `total` equals 0; `resolved` equals 0; `requiring_update` equals 0

#### Test Case: UTP-030-B (Equivalence Partitioning — extractive vs non-extractive parent change)

**Technique**: Equivalence Partitioning
**Target View**: Internal Data Structures
**Description**: Partitions the parent annotation check into extractive (auto-resolve) and non-extractive (manual review) classes.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| get_annotation_for_id | Helper | Stub per partition | Controlled annotation text |

* **Unit Scenario: UTS-030-B1** (partition: extractive — contains "extracted to overlay")
  * **Arrange**: Stub returns annotation with `"extracted to overlay"`
  * **Act**: Call `resolve_extractive_suspects(suspect_items)`
  * **Assert**: Item resolved automatically

* **Unit Scenario: UTS-030-B2** (partition: extractive — contains "relocated to overlay")
  * **Arrange**: Stub returns annotation with `"relocated to overlay"`
  * **Act**: Call `resolve_extractive_suspects(suspect_items)`
  * **Assert**: Item resolved automatically

* **Unit Scenario: UTS-030-B3** (partition: non-extractive — no overlay keywords)
  * **Arrange**: Stub returns `"[MODIFIED — Functional logic changed]"`
  * **Act**: Call `resolve_extractive_suspects(suspect_items)`
  * **Assert**: Item NOT resolved; marked as requiring manual update

#### Test Case: UTP-030-C (Strict Isolation — get_annotation_for_id dependency)

**Technique**: Strict Isolation
**Target View**: Architecture Interface View
**Description**: Verifies `get_annotation_for_id` is properly stubbed and called once per suspect item.

**Dependency & Mock Registry:**

| Dependency | Source | Mock/Stub Strategy | Rationale |
|------------|--------|-------------------|-----------|
| get_annotation_for_id | Helper | Function stub with call counter | Verify invocation count |

* **Unit Scenario: UTS-030-C1** (3 suspects — helper called 3 times)
  * **Arrange**: Set up call-tracking stub; provide 3 suspect items with different parent_ids
  * **Act**: Call `resolve_extractive_suspects(suspect_items)`
  * **Assert**: `get_annotation_for_id` call count equals 3; each call received correct `parent_id`

---

## External Module Bypass

None — all 30 modules are internal, non-`[EXTERNAL]`. No modules bypassed.

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Modules (MOD) | 30 |
| Modules tested | 30 |
| Modules bypassed ([EXTERNAL]) | 0 |
| Total Test Cases (UTP) | 62 (62 active, 0 deprecated, 0 suspect) |
| Total Scenarios (UTS) | 207 |
| Modules with ≥1 UTP | 30 / 30 (100%) (active items only) |
| Test Cases with ≥1 UTS | 58 / 58 (100%) |
| **Overall Coverage (MOD→UTP)** | **100%** (active items only) |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Statement & Branch Coverage | 30 | 48.4% |
| Boundary Value Analysis | 14 | 22.6% |
| Equivalence Partitioning | 9 | 14.5% |
| Strict Isolation | 9 | 14.5% |
| State Transition Testing | 0 | 0% |

### Language Compliance

- Zero user-journey phrases ✅
- Zero integration-boundary phrases ✅
- Zero system-level phrases ✅
- All scenarios in Arrange/Act/Assert format ✅

## MOD→UTP Coverage Matrix

| MOD | UTP(s) | Techniques |
|-----|--------|------------|
| MOD-001 | UTP-001-A | S&BC |
| MOD-002 | UTP-002-A, UTP-002-B | S&BC, EP |
| MOD-003 | UTP-003-A, UTP-003-B, UTP-003-C | S&BC, BVA, SI |
| MOD-004 | UTP-004-A, UTP-004-B | S&BC, SI |
| MOD-005 | UTP-005-A, UTP-005-B | S&BC, BVA |
| MOD-006 | UTP-006-A, UTP-006-B | S&BC, SI |
| MOD-007 | UTP-007-A, UTP-007-B | S&BC, EP |
| MOD-008 | UTP-008-A, UTP-008-B, UTP-008-C | S&BC, EP, SI |
| MOD-009 | UTP-009-A, UTP-009-B, UTP-009-C | S&BC, BVA, EP |
| MOD-010 | UTP-010-A, UTP-010-B | S&BC, BVA |
| MOD-011 | UTP-011-A, UTP-011-B | S&BC, BVA |
| MOD-012 | UTP-012-A | S&BC |
| MOD-013 | UTP-013-A, UTP-013-B | S&BC, BVA |
| MOD-014 | UTP-014-A | S&BC |
| MOD-015 | UTP-015-A, UTP-015-B, UTP-015-C | S&BC, EP, SI |
| MOD-016 | UTP-016-A, UTP-016-B, UTP-016-C | S&BC, BVA, EP |
| MOD-017 | UTP-017-A, UTP-017-B | S&BC, BVA |
| MOD-018 | UTP-018-A, UTP-018-B | S&BC, BVA |
| MOD-019 | UTP-019-A, UTP-019-B | S&BC, BVA |
| MOD-020 | UTP-020-A | S&BC |
| MOD-021 | UTP-021-A, UTP-021-B | S&BC, BVA |
| MOD-022 | UTP-022-A | S&BC |
| MOD-023 | UTP-023-A, UTP-023-B | S&BC, BVA |
| MOD-024 | UTP-024-A | S&BC |
| MOD-025 | UTP-025-A, UTP-025-B, UTP-025-C | S&BC, BVA, SI |
| MOD-026 | UTP-026-A, UTP-026-B | S&BC, EP |
| MOD-027 | UTP-027-A, UTP-027-B | S&BC, BVA |
| MOD-028 | UTP-028-A, UTP-028-B, UTP-028-C | S&BC, EP, SI |
| MOD-029 | UTP-029-A, UTP-029-B | S&BC, SI |
| MOD-030 | UTP-030-A, UTP-030-B, UTP-030-C | S&BC, EP, SI |

## Uncovered Modules

None — full coverage achieved.
