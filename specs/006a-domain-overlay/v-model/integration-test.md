# Integration Test Plan: Domain Overlay Architecture


**Feature Branch**: `feature/006a-domain-overlay`
**Created**: 2025-07-19
**Status**: Draft
**Source**: `specs/006a-domain-overlay/v-model/architecture-design.md`

## Overview

This document defines the Integration Test Plan for the Domain Overlay Architecture feature. Every architecture module in `architecture-design.md` has one or more Test Cases (ITP), and every Test Case has one or more executable Integration Scenarios (ITS) in module-boundary BDD format (Given/When/Then). Integration tests verify **seams and handshakes between modules**, not internal logic or user journeys. The plan covers 18 architecture modules across four implementation layers: Overlay Infrastructure (ARCH-001–005), Content Analysis & Cleaning (ARCH-006–011), Content Population (ARCH-012–015), and Cross-Feature Lifecycle (ARCH-016–018). Key integration boundaries include the scan→clean→verify→inject refactoring pipeline, the parse→extract template chain, the populate→manifest→validate overlay chain, and the map→annotate→cascade lifecycle chain. Two concurrency test points exist: ARCH-007∥ARCH-008 (parallel MIXED/HARDCODED cleaning) and ARCH-012∥ARCH-013∥ARCH-014 (parallel domain population).

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
| **Concurrency & Race Condition Testing** | Process View | Simultaneous access, lock handling, queue ordering |

## Integration Tests

### Module Verification: ARCH-001 (Overlay Directory Scaffold)

**Parent System Components**: SYS-001, SYS-002

#### Test Case: ITP-001-A (Directory scaffold output consumed by downstream modules)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-001's created directory paths are correctly consumed by ARCH-003 (manifest generation), ARCH-011 (template extraction), and ARCH-012/013/014 (content population).

* **Integration Scenario: ITS-001-A1**
  * **Given** ARCH-001 has created the 6 overlay directories (3 domains × 2 roots)
  * **When** ARCH-003 (Domain Manifest Generator) receives domain_id `iso_26262` and attempts to write `_domain.yml` to `commands/overlays/iso_26262/`
  * **Then** the directory path returned by ARCH-001 resolves to a writable filesystem location and ARCH-003 writes the manifest without path resolution errors

* **Integration Scenario: ITS-001-A2**
  * **Given** ARCH-001 has created `templates/overlays/iso_26262/`
  * **When** ARCH-011 (Template Content Extractor) attempts to write `-overlay.md` files to that directory
  * **Then** the write completes and the overlay files are present at the expected paths

#### Test Case: ITP-001-B (Idempotent scaffold re-execution)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verify ARCH-001 handles the case where directories already exist from a prior execution without corrupting existing content written by downstream modules.

* **Integration Scenario: ITS-001-B1**
  * **Given** ARCH-001 has previously created the 6 overlay directories and ARCH-012 has populated overlay files in `commands/overlays/iso_26262/`
  * **When** ARCH-001 is re-executed (idempotent pass)
  * **Then** ARCH-001 reports `dir_exists` for all 6 directories without error and the existing overlay files written by ARCH-012 remain intact and unmodified

---

### Module Verification: ARCH-002 (Domain Manifest Schema Validator)

**Parent System Components**: SYS-003

#### Test Case: ITP-002-A (Manifest validation contract between ARCH-003 and ARCH-002)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-003's generated manifest output conforms to ARCH-002's expected input schema and that ARCH-002's validation result is correctly consumed by ARCH-003.

* **Integration Scenario: ITS-002-A1**
  * **Given** ARCH-003 has generated a `_domain.yml` manifest for `iso_26262` with all required fields (`name`, `standards`, `classification`, `commands`)
  * **When** ARCH-003 sends the manifest content and the directory file listing to ARCH-002 for validation
  * **Then** ARCH-002 returns `{valid: true, errors: []}` with empty `orphan_entries` and empty `unlisted_files`

* **Integration Scenario: ITS-002-A2**
  * **Given** ARCH-003 has generated a manifest with a `commands` list that includes `"system-design"` but the directory contains no `system-design.md` file
  * **When** ARCH-003 sends the manifest and directory listing to ARCH-002
  * **Then** ARCH-002 returns `orphan_entries: ["system-design"]` indicating a manifest-filesystem mismatch

#### Test Case: ITP-002-B (Malformed manifest rejected at validation boundary)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verify ARCH-002 correctly rejects malformed input from ARCH-003 and that the error propagates back to ARCH-003 as a `validation_failed` exception.

* **Integration Scenario: ITS-002-B1**
  * **Given** ARCH-003 sends a manifest with the `classification` field omitted
  * **When** ARCH-002 validates the manifest against the required schema
  * **Then** ARCH-002 returns `{valid: false, errors: ["missing required field: classification"]}` and ARCH-003 raises `validation_failed`

---

### Module Verification: ARCH-003 (Domain Manifest Generator)

**Parent System Components**: SYS-003

#### Test Case: ITP-003-A (Manifest generation triggered by content populators)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-012/013/014 (content populators) correctly trigger ARCH-003 manifest generation after populating overlay files, and the generated manifest accurately reflects the files present.

* **Integration Scenario: ITS-003-A1**
  * **Given** ARCH-012 (ISO 26262 Content Populator) has written 9 command overlay files to `commands/overlays/iso_26262/`
  * **When** ARCH-012 sends a manifest generation request to ARCH-003 with domain_id `iso_26262` and the list of 9 overlay file names
  * **Then** ARCH-003 generates `_domain.yml` with a `commands` list containing all 9 file names and passes ARCH-002 validation

#### Test Case: ITP-003-B (Manifest generation in the overlay population data flow)

**Technique**: Data Flow Testing
**Target View**: Data Flow View (Overlay Population Chain, Stage 2)
**Description**: Verify data flows correctly from ARCH-012/013/014 (stage 1) through ARCH-003 (stage 2) to ARCH-002 (stage 3) in the Overlay Population Chain.

* **Integration Scenario: ITS-003-B1**
  * **Given** ARCH-014 (IEC 62304 Populator) has written 3 command overlay files to `commands/overlays/iec_62304/`
  * **When** data flows from ARCH-014 to ARCH-003 (overlay file list + domain metadata) and then to ARCH-002 (manifest YAML + directory listing)
  * **Then** at stage 2, ARCH-003 produces a `_domain.yml` containing `commands: [hazard-analysis, trace, peer-review]`
  * **And** at stage 3, ARCH-002 returns `{valid: true}` with zero orphans and zero unlisted files

---

### Module Verification: ARCH-004 (Config Template Domain Field)

**Parent System Components**: SYS-004

#### Test Case: ITP-004-A (Config template output consumed by ARCH-005 resolver)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-004's modifications to `config-template.yml` produce a file that ARCH-005 can parse to resolve the domain field.

* **Integration Scenario: ITS-004-A1**
  * **Given** ARCH-004 has added the commented-out `# domain:` field to `config-template.yml`
  * **When** a user uncomments the field and sets `domain: iso_26262`, and ARCH-005 reads the resulting `v-model-config.yml`
  * **Then** ARCH-005 resolves domain_id as `"iso_26262"` and constructs overlay_paths `{commands: "commands/overlays/iso_26262/", templates: "templates/overlays/iso_26262/"}`

* **Integration Scenario: ITS-004-A2**
  * **Given** ARCH-004 has added the commented-out `# domain:` field and the user has NOT uncommented it
  * **When** ARCH-005 reads the config file with the domain field still commented out
  * **Then** ARCH-005 resolves domain_id as `null` and overlay_paths as `null`

---

### Module Verification: ARCH-005 (Domain Field Resolver)

**Parent System Components**: SYS-004

#### Test Case: ITP-005-A (Resolved domain consumed by ARCH-009 instruction block)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-005's resolution output (domain_id + overlay_paths) is correctly consumed by the standardized loading instruction injected by ARCH-009 into command files.

* **Integration Scenario: ITS-005-A1**
  * **Given** ARCH-005 resolves domain_id as `"do_178c"` with overlay_paths `{commands: "commands/overlays/do_178c/"}`
  * **When** a refactored command file (processed by ARCH-009) follows the standardized loading instruction
  * **Then** the instruction resolves the overlay path `commands/overlays/do_178c/{command-name}.md` and the overlay content is appended after base content

* **Integration Scenario: ITS-005-A2**
  * **Given** ARCH-005 resolves domain_id as `null` (no domain configured)
  * **When** a refactored command file follows the standardized loading instruction
  * **Then** the instruction skips overlay loading and only base content is used

#### Test Case: ITP-005-B (Graceful fallback does not propagate errors to downstream modules)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verify ARCH-005's graceful fallback (unsupported domain, missing file) does not generate errors that disrupt ARCH-009 or any command execution.

* **Integration Scenario: ITS-005-B1**
  * **Given** ARCH-005 receives `domain: iec_61508` (unsupported value with no overlay directory)
  * **When** ARCH-005 resolves the domain and the result is passed to a command's loading instruction
  * **Then** ARCH-005 returns domain_id as `null` and the command proceeds with base content only — no error, no warning propagated to the command execution

---

### Module Verification: ARCH-006 (Domain Term Scanner)

**Parent System Components**: SYS-005

#### Test Case: ITP-006-A (Scan report consumed by ARCH-007 and ARCH-008)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-006's scan report output format matches the input contract of ARCH-007 (MIXED cleaner) and ARCH-008 (HARDCODED cleaner).

* **Integration Scenario: ITS-006-A1**
  * **Given** ARCH-006 scans `commands/system-design.md` and finds 3 banned terms at lines 45, 78, and 112
  * **When** ARCH-006 sends the scan report `[{term: "ISO 26262", line: 45, context: "..."}, ...]` to ARCH-007
  * **Then** ARCH-007 receives all 3 entries with valid `term`, `line_number`, and `context` fields and uses them to locate and remove the banned terms

* **Integration Scenario: ITS-006-A2**
  * **Given** ARCH-006 scans `commands/trace.md` and finds 5 banned terms
  * **When** ARCH-006 sends the scan report to ARCH-008
  * **Then** ARCH-008 receives all 5 entries in the expected `[{term, line_number, context}]` format

#### Test Case: ITP-006-B (Scan report in the refactoring data flow)

**Technique**: Data Flow Testing
**Target View**: Data Flow View (Base Command Refactoring Chain, Stage 1→2→3)
**Description**: Verify the scan report data flows correctly from ARCH-006 (stage 1) through ARCH-007/008 (stages 2–3) in the refactoring chain.

* **Integration Scenario: ITS-006-B1**
  * **Given** ARCH-006 produces a scan report with entries `[{term: "ASIL", line: 15}, {term: "DO-178C", line: 42}]` for a MIXED command file
  * **When** data flows from ARCH-006 (stage 1) to ARCH-007 (stage 2)
  * **Then** ARCH-007 transforms the Markdown command file from contaminated to cleaned format
  * **And** the output file at stage 2 contains zero instances of "ASIL" or "DO-178C"

#### Test Case: ITP-006-C (Post-cleaning verification loop between ARCH-006 and ARCH-007/008)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify the verification feedback loop: ARCH-007/008 request a post-cleaning scan from ARCH-006, and ARCH-006's `is_clean: true` result gates ARCH-009.

* **Integration Scenario: ITS-006-C1**
  * **Given** ARCH-007 has cleaned 6 MIXED command files
  * **When** ARCH-007 sends all 6 cleaned file paths back to ARCH-006 for verification
  * **Then** ARCH-006 returns `is_clean: true` for each file and the pipeline proceeds to ARCH-009

* **Integration Scenario: ITS-006-C2**
  * **Given** ARCH-008 has cleaned 3 HARDCODED command files but one still contains "regulatory-grade"
  * **When** ARCH-008 sends the 3 cleaned file paths to ARCH-006 for verification
  * **Then** ARCH-006 returns `is_clean: false` for the file with the remnant and ARCH-008 raises `incomplete_cleaning` — the pipeline does NOT proceed to ARCH-009

---

### Module Verification: ARCH-007 (MIXED Command Cleaner)

**Parent System Components**: SYS-005

#### Test Case: ITP-007-A (Cleaned output consumed by ARCH-009)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-007's cleaned command files meet ARCH-009's input requirements for instruction injection.

* **Integration Scenario: ITS-007-A1**
  * **Given** ARCH-007 has cleaned `commands/system-design.md` with zero banned terms remaining
  * **When** ARCH-009 receives the cleaned file path
  * **Then** ARCH-009 successfully injects exactly one standardized loading instruction block without encountering ad-hoc conditional patterns that would conflict

#### Test Case: ITP-007-B (Cleaned output consumed by ARCH-012 for overlay content sourcing)

**Technique**: Data Flow Testing
**Target View**: Data Flow View (Base Command Refactoring Chain → Overlay Population Chain)
**Description**: Verify the domain-specific content extracted by ARCH-007 during cleaning is available as input to ARCH-012/013/014 for overlay population.

* **Integration Scenario: ITS-007-B1**
  * **Given** ARCH-007 has extracted domain-specific content from the 6 MIXED commands during cleaning
  * **When** ARCH-012 (ISO 26262 Populator) requests the extracted command content for `system-design`
  * **Then** the extracted content is available in the expected `{command_name → domain-specific Markdown}` format and contains the ISO 26262-specific sections that were removed from the base command

#### Test Case: ITP-007-C (Parallel execution with ARCH-008 on disjoint file sets)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View (Base Content Refactoring Pipeline)
**Description**: Verify ARCH-007 and ARCH-008 can execute concurrently without interference since they operate on disjoint file sets (6 MIXED vs. 3 HARDCODED).

* **Integration Scenario: ITS-007-C1**
  * **Given** ARCH-006 has completed scanning and provided scan reports to both ARCH-007 and ARCH-008
  * **When** ARCH-007 cleans the 6 MIXED files and ARCH-008 cleans the 3 HARDCODED files concurrently
  * **Then** both modules complete without file access conflicts, and the union of their 9 output files matches the expected set of all refactored commands

---

### Module Verification: ARCH-008 (HARDCODED Command Cleaner)

**Parent System Components**: SYS-005

#### Test Case: ITP-008-A (Cleaned output consumed by ARCH-009)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-008's cleaned HARDCODED command files meet ARCH-009's input requirements.

* **Integration Scenario: ITS-008-A1**
  * **Given** ARCH-008 has cleaned `commands/trace.md` with zero banned terms and no unconditional regulatory references remaining
  * **When** ARCH-009 receives the cleaned file path
  * **Then** ARCH-009 successfully injects exactly one standardized loading instruction block

#### Test Case: ITP-008-B (Cleaned output consumed by ARCH-015 for description alignment)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-015 (Extension Description Rewriter) can read ARCH-008's cleaned commands to align description language.

* **Integration Scenario: ITS-008-B1**
  * **Given** ARCH-008 has cleaned `commands/peer-review.md`, replacing "regulatory-grade" with domain-agnostic language
  * **When** ARCH-015 reads the refactored `peer-review.md` to determine appropriate description language
  * **Then** ARCH-015 produces a description for the peer-review command that aligns with the cleaned content — no "regulatory-grade" or domain-specific standard names

#### Test Case: ITP-008-C (Incomplete cleaning detected at verification boundary)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verify that ARCH-008's incomplete cleaning is caught by the ARCH-006 verification loop and does not leak through to ARCH-009.

* **Integration Scenario: ITS-008-C1**
  * **Given** ARCH-008 has attempted to clean `commands/hazard-analysis.md` but a "ISO 14971" reference remains at line 23
  * **When** ARCH-008 sends the file to ARCH-006 for post-cleaning verification
  * **Then** ARCH-006 returns `is_clean: false` with scan_report containing the "ISO 14971" match
  * **And** ARCH-008 raises `incomplete_cleaning` and the pipeline does NOT proceed to ARCH-009

---

### Module Verification: ARCH-009 (Standardized Loading Instruction Injector)

**Parent System Components**: SYS-005

#### Test Case: ITP-009-A (Instruction injection into files cleaned by ARCH-007 and ARCH-008)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-009 correctly injects the standardized loading instruction into all 9 files previously cleaned by ARCH-007 (6) and ARCH-008 (3).

* **Integration Scenario: ITS-009-A1**
  * **Given** ARCH-007 has output 6 cleaned MIXED command files and ARCH-008 has output 3 cleaned HARDCODED command files
  * **When** ARCH-009 receives all 9 file paths and the instruction template referencing `commands/overlays/{domain}/{command-name}.md`
  * **Then** each of the 9 files contains exactly one standardized loading instruction block and `remnant_check.ad_hoc_patterns_found` is 0

#### Test Case: ITP-009-B (Instruction injection in the refactoring data flow)

**Technique**: Data Flow Testing
**Target View**: Data Flow View (Base Command Refactoring Chain, Stage 5)
**Description**: Verify the final stage of the refactoring chain: cleaned-and-verified files (from stages 2–4) are correctly transformed to files with the loading instruction block.

* **Integration Scenario: ITS-009-B1**
  * **Given** a command file has flowed through ARCH-006 (stage 1, scan), ARCH-007 (stage 2, clean), ARCH-006 (stage 4, verify), and is now at the input of ARCH-009 (stage 5)
  * **When** ARCH-009 transforms the file by injecting the loading instruction
  * **Then** the output file format is "Markdown command file (cleaned + instruction block)" matching the chain's expected final output format
  * **And** the instruction block references the correct `{command-name}` derived from the file name

#### Test Case: ITP-009-C (Duplicate injection prevention)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verify ARCH-009 detects and prevents duplicate injection if a file already contains a loading instruction block.

* **Integration Scenario: ITS-009-C1**
  * **Given** ARCH-009 has previously injected the loading instruction into `commands/system-design.md`
  * **When** ARCH-009 is re-executed on the same file (idempotent pass)
  * **Then** ARCH-009 raises `duplicate_injection` and skips the file without adding a second instruction block

---

### Module Verification: ARCH-010 (Gate Boundary Parser)

**Parent System Components**: SYS-006

#### Test Case: ITP-010-A (Gate block output consumed by ARCH-011)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-010's gate block list output matches ARCH-011's expected input contract.

* **Integration Scenario: ITS-010-A1**
  * **Given** ARCH-010 has parsed `templates/system-design-template.md` and identified 2 gate blocks: `{start: 85, end: 120, type: "SAFETY-CRITICAL SECTION", content: "..."}` and `{start: 145, end: 170, type: "DOMAIN-SPECIFIC SCALES", content: "..."}`
  * **When** ARCH-010 sends the gate block list to ARCH-011
  * **Then** ARCH-011 receives both blocks with valid `start_line`, `end_line`, `gate_type`, and `content` fields and proceeds to extract content

#### Test Case: ITP-010-B (Gate block data flow into template extraction chain)

**Technique**: Data Flow Testing
**Target View**: Data Flow View (Template Extraction Chain, Stage 1→2)
**Description**: Verify data flows from ARCH-010 (stage 1: parse) through ARCH-011 (stage 2: extract) in the Template Extraction Chain.

* **Integration Scenario: ITS-010-B1**
  * **Given** ARCH-010 produces gate block list `[{start: 85, end: 120, type: "SAFETY-CRITICAL SECTION", content: "<ISO 26262 content>"}]` for a GATED template
  * **When** data flows from ARCH-010 (stage 1) to ARCH-011 (stage 2)
  * **Then** ARCH-011 extracts the content between lines 85–120 into `-overlay.md` files and removes lines 85–120 (including gate comments) from the base template

#### Test Case: ITP-010-C (Malformed gate propagation to ARCH-011)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verify ARCH-010 handles malformed gates (opening comment without matching close) and that the error does not propagate silently to ARCH-011.

* **Integration Scenario: ITS-010-C1**
  * **Given** a template file contains `<!-- SAFETY-CRITICAL SECTION -->` at line 85 but no matching closing comment
  * **When** ARCH-010 attempts to parse the gate boundaries
  * **Then** ARCH-010 raises `malformed_gate` with the line number 85 and ARCH-011 does NOT receive a gate block list for this template

---

### Module Verification: ARCH-011 (Template Content Extractor)

**Parent System Components**: SYS-006

#### Test Case: ITP-011-A (Extracted content written to ARCH-001 directories)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-011's overlay file output is written to the directory paths created by ARCH-001.

* **Integration Scenario: ITS-011-A1**
  * **Given** ARCH-001 has created `templates/overlays/iso_26262/` and ARCH-010 has provided gate blocks for `templates/system-design-template.md`
  * **When** ARCH-011 extracts the gated content with target_domains `["iso_26262", "do_178c", "iec_62304"]`
  * **Then** ARCH-011 creates `templates/overlays/iso_26262/system-design-overlay.md` (and equivalents for other domains) in the directories created by ARCH-001

#### Test Case: ITP-011-B (Directory missing from ARCH-001)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verify ARCH-011 correctly fails when a target directory (from ARCH-001) does not exist.

* **Integration Scenario: ITS-011-B1**
  * **Given** ARCH-001 has NOT been executed and `templates/overlays/iso_26262/` does not exist
  * **When** ARCH-011 attempts to write `-overlay.md` files to that directory
  * **Then** ARCH-011 raises `target_dir_missing` and no partial files are created

---

### Module Verification: ARCH-012 (ISO 26262 Content Populator)

**Parent System Components**: SYS-007

#### Test Case: ITP-012-A (Overlay files trigger ARCH-003 manifest generation)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-012 correctly triggers ARCH-003 to generate the ISO 26262 manifest after populating overlay files.

* **Integration Scenario: ITS-012-A1**
  * **Given** ARCH-012 has populated ≥9 command overlay files in `commands/overlays/iso_26262/`
  * **When** ARCH-012 sends the manifest generation request to ARCH-003 with domain_id `iso_26262` and the full file list
  * **Then** ARCH-003 generates `_domain.yml` with a `commands` list containing all populated file names and ARCH-002 validates it as `{valid: true}`

#### Test Case: ITP-012-B (Content sourced from ARCH-007/008 and ARCH-011)

**Technique**: Data Flow Testing
**Target View**: Data Flow View (Overlay Population Chain, Stage 1)
**Description**: Verify ARCH-012 correctly sources extracted content from ARCH-007/008 (command content) and ARCH-011 (template content).

* **Integration Scenario: ITS-012-B1**
  * **Given** ARCH-007 has extracted ISO 26262 domain-specific content from `system-design.md` during cleaning and ARCH-011 has extracted gated template content
  * **When** ARCH-012 reads the extracted command content map and template content map
  * **Then** ARCH-012 creates overlay files containing the ISO 26262-specific content using preference-based indirection language and both command and template overlay files are present

#### Test Case: ITP-012-C (Parallel execution with ARCH-013 and ARCH-014)

**Technique**: Concurrency & Race Condition Testing
**Target View**: Process View (Overlay Content Population)
**Description**: Verify ARCH-012, ARCH-013, and ARCH-014 can populate their respective domain directories concurrently without interference.

* **Integration Scenario: ITS-012-C1**
  * **Given** ARCH-007/008 cleaning and ARCH-011 extraction have completed
  * **When** ARCH-012 populates `iso_26262/`, ARCH-013 populates `do_178c/`, and ARCH-014 populates `iec_62304/` concurrently
  * **Then** all three populators complete without file access conflicts
  * **And** each domain directory contains its expected minimum file count (iso_26262: ≥9, do_178c: ≥6, iec_62304: ≥3) with no cross-domain content contamination

#### Test Case: ITP-012-D (Missing extracted content for required command)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verify ARCH-012 handles the case where expected extracted content from ARCH-007/008 is unavailable for a required command.

* **Integration Scenario: ITS-012-D1**
  * **Given** ARCH-012 expects extracted content for `system-design` but the content map from ARCH-007 contains no entry for `system-design`
  * **When** ARCH-012 attempts to populate the `iso_26262/system-design.md` overlay
  * **Then** ARCH-012 raises `content_missing` with a message identifying the missing command and the populator does NOT generate an incomplete overlay set

---

### Module Verification: ARCH-013 (DO-178C Content Populator)

**Parent System Components**: SYS-007

#### Test Case: ITP-013-A (Overlay files trigger ARCH-003 manifest generation)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-013 correctly triggers ARCH-003 to generate the DO-178C manifest after populating overlay files.

* **Integration Scenario: ITS-013-A1**
  * **Given** ARCH-013 has populated ≥6 command overlay files in `commands/overlays/do_178c/`
  * **When** ARCH-013 sends the manifest generation request to ARCH-003 with domain_id `do_178c`
  * **Then** ARCH-003 generates `_domain.yml` with a `commands` list matching the populated files and ARCH-002 validates it as `{valid: true}`

---

### Module Verification: ARCH-014 (IEC 62304 Content Populator)

**Parent System Components**: SYS-007

#### Test Case: ITP-014-A (Overlay files trigger ARCH-003 manifest generation)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-014 correctly triggers ARCH-003 to generate the IEC 62304 manifest after populating overlay files.

* **Integration Scenario: ITS-014-A1**
  * **Given** ARCH-014 has populated ≥3 command overlay files in `commands/overlays/iec_62304/`
  * **When** ARCH-014 sends the manifest generation request to ARCH-003 with domain_id `iec_62304`
  * **Then** ARCH-003 generates `_domain.yml` with a `commands` list matching the populated files and ARCH-002 validates it as `{valid: true}`

---

### Module Verification: ARCH-015 (Extension Description Rewriter)

**Parent System Components**: SYS-008

#### Test Case: ITP-015-A (Description language aligned with ARCH-007/008 refactored content)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-015 reads the refactored commands from ARCH-007/008 to ensure the rewritten descriptions align with the cleaned base content.

* **Integration Scenario: ITS-015-A1**
  * **Given** ARCH-007 has cleaned `commands/system-design.md` removing all ISO 26262 references and ARCH-008 has cleaned `commands/peer-review.md` removing all regulatory references
  * **When** ARCH-015 reads both refactored files and rewrites their descriptions in `extension.yml`
  * **Then** the `system-design` description contains no "ISO 26262" or "safety-compliant" and the `peer-review` description contains no "regulatory-grade"
  * **And** both descriptions preserve their functional purpose

#### Test Case: ITP-015-B (Safety-critical tag inadvertently removed during editing)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verify ARCH-015 detects if the `safety-critical` tag is inadvertently removed during description rewriting and raises an error.

* **Integration Scenario: ITS-015-B1**
  * **Given** ARCH-015 is editing `extension.yml` and the `safety-critical` tag is present in the `tags` section
  * **When** ARCH-015 completes the description rewriting and performs post-edit validation
  * **Then** the `safety-critical` tag remains in the `tags` section — if missing, ARCH-015 raises `tag_removed` error

---

### Module Verification: ARCH-016 (Parent Feature Mapper)

**Parent System Components**: SYS-009

#### Test Case: ITP-016-A (Mapping table consumed by ARCH-017)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-016's mapping table output matches ARCH-017's expected input contract.

* **Integration Scenario: ITS-016-A1**
  * **Given** ARCH-016 receives the list of 9 refactored command names (from ARCH-007 and ARCH-008 outputs)
  * **When** ARCH-016 maps them using the fixed mapping and sends the result to ARCH-017
  * **Then** ARCH-017 receives 9 mapping entries in format `[{command: "system-design", feature_id: "002", artifact_paths: [...]}, ...]` with all commands mapped

#### Test Case: ITP-016-B (Mapping table in the lifecycle data flow)

**Technique**: Data Flow Testing
**Target View**: Data Flow View (Cross-Feature Lifecycle Chain, Stage 1→2)
**Description**: Verify data flows correctly from ARCH-016 (stage 1) through ARCH-017 (stage 2) in the lifecycle chain.

* **Integration Scenario: ITS-016-B1**
  * **Given** ARCH-016 produces mapping table with entry `{command: "trace", feature_id: "001", artifact_paths: ["specs/001-.../v-model/requirements.md"]}`
  * **When** data flows from ARCH-016 (stage 1) to ARCH-017 (stage 2)
  * **Then** ARCH-017 uses the artifact_paths to locate Feature 001's `requirements.md` and applies the HARDCODED annotation template: `[MODIFIED — Unconditional domain-specific content removed from base and relocated to overlay per Feature 006a]`

---

### Module Verification: ARCH-017 (MODIFIED Annotation Writer)

**Parent System Components**: SYS-009

#### Test Case: ITP-017-A (Annotated output consumed by ARCH-018)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-017's list of MODIFIED IDs matches ARCH-018's expected input contract for cascade processing.

* **Integration Scenario: ITS-017-A1**
  * **Given** ARCH-017 has applied `[MODIFIED]` annotations to 5 requirement IDs across Features 001–005
  * **When** ARCH-017 sends the list of modified IDs `[{id: "REQ-...", artifact_path: "...", annotation: "[MODIFIED — ...]"}]` to ARCH-018
  * **Then** ARCH-018 receives all 5 entries with valid `id`, `artifact_path`, and `annotation` fields

#### Test Case: ITP-017-B (Feature 006b unavailable blocks lifecycle pipeline)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verify ARCH-017 blocks when Feature 006b's lifecycle model is unavailable and does not pass incomplete annotations to ARCH-018.

* **Integration Scenario: ITS-017-B1**
  * **Given** ARCH-016 has provided a valid mapping table to ARCH-017 but Feature 006b's lifecycle model is NOT implemented
  * **When** ARCH-017 attempts to apply `[MODIFIED]` annotations
  * **Then** ARCH-017 raises `lifecycle_unavailable` with message "Feature 006b lifecycle model required for cross-feature evolution"
  * **And** ARCH-018 receives NO input — the lifecycle pipeline is halted

---

### Module Verification: ARCH-018 (SUSPECT Cascade Engine)

**Parent System Components**: SYS-009

#### Test Case: ITP-018-A (Cascade from ARCH-017 MODIFIED IDs to downstream artifacts)

**Technique**: Interface Contract Testing
**Target View**: Interface View
**Description**: Verify ARCH-018 correctly consumes ARCH-017's MODIFIED ID list and cascades SUSPECT annotations to downstream artifacts.

* **Integration Scenario: ITS-018-A1**
  * **Given** ARCH-017 has provided `[{id: "REQ-005", artifact_path: "specs/002-.../v-model/requirements.md"}]` indicating a MODIFIED requirement
  * **When** ARCH-018 traverses the traceability chain from REQ-005 to its downstream acceptance test cases
  * **Then** ARCH-018 marks each downstream ATP tracing to REQ-005 as `[SUSPECT — Parent REQ-005 modified]`
  * **And** the resolution_summary reports the total count of SUSPECT items

#### Test Case: ITP-018-B (Lifecycle data flow end-to-end chain)

**Technique**: Data Flow Testing
**Target View**: Data Flow View (Cross-Feature Lifecycle Chain, Stages 1→2→3)
**Description**: Verify the complete data flow through the lifecycle chain from ARCH-016 (mapping) through ARCH-017 (annotation) to ARCH-018 (cascade).

* **Integration Scenario: ITS-018-B1**
  * **Given** a refactored command `system-design` has been mapped by ARCH-016 to Feature 002
  * **When** data flows through ARCH-016 (mapping table) → ARCH-017 (MODIFIED annotations on Feature 002 artifacts) → ARCH-018 (SUSPECT cascade on Feature 002 downstream artifacts)
  * **Then** at stage 3, ARCH-018 produces annotated files with `[SUSPECT]` markers on all downstream artifacts tracing to the MODIFIED IDs
  * **And** the resolution_summary for extractive-only changes shows `resolved` count matching `total` count (all confirmed still valid)

#### Test Case: ITP-018-C (Traceability gap detected)

**Technique**: Interface Fault Injection
**Target View**: Interface View + Process View
**Description**: Verify ARCH-018 detects and reports when a MODIFIED ID from ARCH-017 has no downstream traceability chain.

* **Integration Scenario: ITS-018-C1**
  * **Given** ARCH-017 provides `[{id: "SYS-007", artifact_path: "..."}]` but no downstream artifacts trace to SYS-007
  * **When** ARCH-018 attempts to cascade SUSPECT annotations
  * **Then** ARCH-018 raises `traceability_gap` reporting that SYS-007 has no downstream trace and the gap is logged for human review

---

## Test Harness & Mocking Strategy

| Test Case | External Dependency | Mock/Stub Strategy | Rationale |
|-----------|--------------------|--------------------|-----------|
| ITP-001-A, ITP-001-B | Filesystem (directory creation) | Real filesystem in temp directory | Directory operations must be verified against actual filesystem behavior |
| ITP-002-A, ITP-002-B | YAML parser | Real YAML parser | Manifest validation depends on actual YAML parsing behavior |
| ITP-004-A, ITP-005-A, ITP-005-B | `v-model-config.yml` | Fixture files per scenario | Each scenario requires a different config state (present/absent/empty/unsupported) |
| ITP-006-A through ITP-006-C | Markdown command files | Fixture files with known banned terms at known lines | Deterministic scan results require controlled input content |
| ITP-007-B, ITP-008-B | Extracted content map | Stub content map | Simulates ARCH-007/008 extraction output without running full cleaning pipeline |
| ITP-007-C | Parallel file access | Real filesystem, concurrent execution | Must verify actual absence of file access conflicts |
| ITP-012-C | Parallel directory writes | Real filesystem, concurrent execution | Must verify actual absence of cross-domain contamination |
| ITP-012-D | Content map | Stub with missing entry | Simulates extraction failure for required command |
| ITP-017-B | Feature 006b availability | Stub lifecycle model check | Simulates unavailable lifecycle model to test blocking behavior |
| ITP-018-A, ITP-018-B | Traceability chain data | Fixture parent feature V-Model artifacts | Requires known traceability links for cascade verification |
| ITP-018-C | Traceability chain data | Fixture with intentional gap | Simulates missing downstream trace |

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Architecture Modules (ARCH) | 18 (18 active, 0 deprecated) |
| Total Test Cases (ITP) | 41 (41 active, 0 deprecated, 0 suspect) |
| Total Scenarios (ITS) | 47 |
| Modules with ≥1 ITP | 18 / 18 (100%) (active items only) |
| Test Cases with ≥1 ITS | 41 / 41 (100%) |
| **Overall Coverage (ARCH→ITP)** | **100%** (active items only) |

### Technique Distribution

| Technique | Test Cases | Percentage |
|-----------|-----------|------------|
| Interface Contract Testing | 20 | 49% |
| Data Flow Testing | 8 | 19% |
| Interface Fault Injection | 11 | 27% |
| Concurrency & Race Condition Testing | 2 | 5% |
| **Total** | **41** | **100%** |

## Uncovered Modules

None — full coverage achieved.
