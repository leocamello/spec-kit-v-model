# System Test Plan: Domain Overlay Architecture


**Feature Branch**: `feature/006a-domain-overlay`
**Created**: 2025-07-19
**Status**: Draft
**Source**: `specs/006a-domain-overlay/v-model/system-design.md`

## Overview

This document defines the System Test Plan for the Domain Overlay Architecture feature. Every system component in `system-design.md` has one or more Test Cases (STP), and every Test Case has one or more executable System Scenarios (STS) in technical BDD format (Given/When/Then). System tests verify architectural behavior, not user journeys. Language is technical and component-oriented. The plan covers 9 system components: overlay directory structures, domain manifests, configuration gateway, base command refactoring, template overlay extraction, domain overlay content sets, extension metadata, and cross-feature lifecycle coordination. Because this feature restructures content (not runtime behavior), system tests focus on file structure verification, content correctness, composition behavior, and cross-reference integrity.

## ID Schema

- **System Test Case**: `STP-{NNN}-{X}` — where NNN matches the parent SYS, X is a letter suffix (A, B, C...)
- **System Test Scenario**: `STS-{NNN}-{X}{#}` — nested under the parent STP, with numeric suffix (1, 2, 3...)
- Example: `STS-001-A1` → Scenario 1 of Test Case A verifying SYS-001

## ISO 29119 Test Techniques

Each test case MUST identify its technique by name:
- **Interface Contract Testing** — Verifies API contracts from the Interface View
- **Boundary Value Analysis** — Tests data limits from the Data Design View
- **Equivalence Partitioning** — Tests representative data classes
- **Fault Injection** — Tests failure propagation from the Dependency View

## System Tests

### Component Verification: SYS-001 (Command Overlay Directory Structure)

**Parent Requirements**: REQ-001, REQ-NF-002

#### Test Case: STP-001-A (Overlay directory hierarchy exists with correct domain subdirectories)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Overlay Content Discovery)
**Description**: Verify the `commands/overlays/` directory contains one subdirectory per supported domain, each named with the correct snake_case domain ID.

* **System Scenario: STS-001-A1**
  * **Given** a clean checkout of the spec-kit-v-model extension at v0.6.0
  * **When** the file system is queried for subdirectories of `commands/overlays/`
  * **Then** exactly 3 subdirectories exist: `iso_26262/`, `do_178c/`, `iec_62304/`
  * **And** each subdirectory name uses snake_case format with no uppercase characters

#### Test Case: STP-001-B (Overlay file names match corresponding base command names)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Overlay Content Discovery)
**Description**: Verify every `.md` file in a domain overlay directory has a corresponding base command file in `commands/`, ensuring the path-based discovery mechanism resolves correctly.

* **System Scenario: STS-001-B1**
  * **Given** the `commands/overlays/iso_26262/` directory contains `.md` overlay files
  * **When** each overlay file name is cross-referenced against the `commands/` base directory (excluding `overlays/`)
  * **Then** every overlay file name (e.g., `system-design.md`) has a matching base command file at `commands/system-design.md`

* **System Scenario: STS-001-B2**
  * **Given** the `commands/overlays/do_178c/` directory contains `.md` overlay files
  * **When** each overlay file name is cross-referenced against the `commands/` base directory
  * **Then** every overlay file name has a matching base command file

#### Test Case: STP-001-C (Empty domain directory does not cause filesystem errors)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify the overlay directory structure handles the boundary condition of a domain directory with zero overlay files.

* **System Scenario: STS-001-C1**
  * **Given** a domain overlay directory `commands/overlays/iec_62304/` containing only `_domain.yml` and no `.md` command overlay files
  * **When** the overlay content discovery mechanism queries this directory for command overlays
  * **Then** the discovery returns zero overlay files without raising an error or exception

---

### Component Verification: SYS-002 (Template Overlay Directory Structure)

**Parent Requirements**: REQ-002, REQ-NF-002

#### Test Case: STP-002-A (Template overlay directory hierarchy exists with domain subdirectories)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Overlay Content Discovery)
**Description**: Verify the `templates/overlays/` directory contains one subdirectory per supported domain with the correct snake_case naming.

* **System Scenario: STS-002-A1**
  * **Given** a clean checkout of the spec-kit-v-model extension at v0.6.0
  * **When** the file system is queried for subdirectories of `templates/overlays/`
  * **Then** exactly 3 subdirectories exist: `iso_26262/`, `do_178c/`, `iec_62304/`

#### Test Case: STP-002-B (Template overlay files use -overlay.md suffix convention)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Overlay Content Discovery)
**Description**: Verify every template overlay file in domain subdirectories uses the `-overlay.md` suffix, distinguishing it from base template files.

* **System Scenario: STS-002-B1**
  * **Given** the `templates/overlays/iso_26262/` directory contains template overlay files
  * **When** each file name is inspected
  * **Then** every file ends with `-overlay.md` (e.g., `system-design-overlay.md`, `module-design-overlay.md`)
  * **And** no file shares the exact name of a base template file in `templates/`

---

### Component Verification: SYS-003 (Domain Manifest System)

**Parent Requirements**: REQ-003, REQ-NF-002

#### Test Case: STP-003-A (Each domain directory contains a valid _domain.yml manifest)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Manifest Validation)
**Description**: Verify every domain overlay directory contains a `_domain.yml` manifest with all required fields: `name`, `standards`, `classification`, and `commands`.

* **System Scenario: STS-003-A1**
  * **Given** the `commands/overlays/iso_26262/` directory
  * **When** the `_domain.yml` manifest is parsed as YAML
  * **Then** the manifest contains `name: "ISO 26262"`, a `standards` list including `"ISO 26262"`, `classification: "ASIL"`, and a `commands` list

* **System Scenario: STS-003-A2**
  * **Given** the `commands/overlays/do_178c/` directory
  * **When** the `_domain.yml` manifest is parsed as YAML
  * **Then** the manifest contains `name: "DO-178C"`, a `standards` list including `"DO-178C"`, `classification: "DAL"`, and a `commands` list

* **System Scenario: STS-003-A3**
  * **Given** the `commands/overlays/iec_62304/` directory
  * **When** the `_domain.yml` manifest is parsed as YAML
  * **Then** the manifest contains `name: "IEC 62304"`, a `standards` list including `"IEC 62304"`, `classification: "Safety Class"`, and a `commands` list

#### Test Case: STP-003-B (Manifest commands list matches actual overlay files in directory)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Manifest Validation)
**Description**: Verify the `commands` list in each `_domain.yml` exactly matches the command overlay files present in the same directory — no missing entries, no orphan entries.

* **System Scenario: STS-003-B1**
  * **Given** `commands/overlays/iso_26262/_domain.yml` with a `commands` list and the directory containing `.md` overlay files
  * **When** the `commands` list entries are compared against the `.md` files in the directory (excluding `_domain.yml`)
  * **Then** every `.md` file's base name appears in the `commands` list
  * **And** every entry in the `commands` list has a corresponding `.md` file in the directory

#### Test Case: STP-003-C (Manifest with missing required field detected)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify the manifest validation identifies manifests with missing required fields.

* **System Scenario: STS-003-C1**
  * **Given** a `_domain.yml` manifest with the `classification` field omitted
  * **When** the manifest is validated against the required schema (`name`, `standards`, `classification`, `commands`)
  * **Then** the validation identifies the missing `classification` field as a schema violation

---

### Component Verification: SYS-004 (Configuration Gateway)

**Parent Requirements**: REQ-004, REQ-007, REQ-008, REQ-CN-003, REQ-CN-004

#### Test Case: STP-004-A (Config template includes documented domain field)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Domain Configuration)
**Description**: Verify `config-template.yml` includes a commented-out `domain` field with documentation listing supported values and the domain-agnostic default.

* **System Scenario: STS-004-A1**
  * **Given** the `config-template.yml` file in the extension directory
  * **When** the file content is parsed
  * **Then** the file contains a commented-out domain field (matching pattern `# domain:`)
  * **And** inline documentation listing `iso_26262`, `do_178c`, `iec_62304` as supported values
  * **And** a statement that omitting or leaving empty activates domain-agnostic mode

#### Test Case: STP-004-B (Domain field values as equivalence classes)

**Technique**: Equivalence Partitioning
**Target View**: Data Design View
**Description**: Verify the `domain` field accepts exactly the 3 supported values, treats empty/absent as domain-agnostic, and handles unsupported values via graceful fallback.

* **System Scenario: STS-004-B1**
  * **Given** a `v-model-config.yml` with `domain: iso_26262`
  * **When** the Configuration Gateway reads the domain field
  * **Then** the domain is resolved as `iso_26262`, enabling overlay paths `commands/overlays/iso_26262/` and `templates/overlays/iso_26262/`

* **System Scenario: STS-004-B2**
  * **Given** a `v-model-config.yml` with `domain:` set to an empty string
  * **When** the Configuration Gateway reads the domain field
  * **Then** the domain is resolved as absent, and no overlay paths are activated

* **System Scenario: STS-004-B3**
  * **Given** a `v-model-config.yml` with no `domain` field present
  * **When** the Configuration Gateway reads the file
  * **Then** the domain is resolved as absent, identical to the empty-string case

* **System Scenario: STS-004-B4**
  * **Given** a project with no `v-model-config.yml` file at the repository root
  * **When** the Configuration Gateway attempts to read the file
  * **Then** the domain is resolved as absent, and the command proceeds in domain-agnostic mode without error

#### Test Case: STP-004-C (Only one domain active at a time)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify the `domain` field accepts only a single scalar value, not a list or multiple values.

* **System Scenario: STS-004-C1**
  * **Given** a `v-model-config.yml` with `domain: iso_26262`
  * **When** a command loads the overlay for `system-design`
  * **Then** only `commands/overlays/iso_26262/system-design.md` is loaded
  * **And** no content from `commands/overlays/do_178c/system-design.md` or `commands/overlays/iec_62304/system-design.md` is appended

#### Test Case: STP-004-D (Graceful fallback for unsupported domain value)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verify that an unsupported `domain` value (one that has no overlay directory) results in graceful fallback to base content without error.

* **System Scenario: STS-004-D1**
  * **Given** a `v-model-config.yml` with `domain: iec_61508` (unsupported — no overlay directory exists)
  * **When** a command attempts to resolve the overlay path `commands/overlays/iec_61508/system-design.md`
  * **Then** the path does not exist, and the command proceeds using only base content
  * **And** no error, warning, or user-visible notification is generated

---

### Component Verification: SYS-005 (Base Command Refactoring Engine)

**Parent Requirements**: REQ-009, REQ-010, REQ-011, REQ-012, REQ-013, REQ-020, REQ-CN-001, REQ-CN-002

#### Test Case: STP-005-A (MIXED commands free of domain-specific terms after refactoring)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Command Composition)
**Description**: Verify all 6 MIXED commands contain zero domain-specific terms after refactoring — the base content references only universally applicable standards.

* **System Scenario: STS-005-A1**
  * **Given** the refactored `commands/system-design.md` base command file
  * **When** the file content is searched for banned terms: ASIL, DAL, SIL, HIL, MC/DC, WCET, MISRA, CERT-C, "regulatory-grade", "Freedom from Interference", "ASIL Decomposition"
  * **Then** zero matches are found

* **System Scenario: STS-005-A2**
  * **Given** the refactored `commands/module-design.md` base command file
  * **When** the file content is searched for banned terms: "DO-178C", "ISO 26262", MISRA, CERT-C, "Single Entry/Exit"
  * **Then** zero matches are found
  * **And** the file references only universally applicable standards (IEEE 1016, INCOSE)

* **System Scenario: STS-005-A3**
  * **Given** all 6 MIXED base command files (`system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`)
  * **When** the file content of each is searched for domain-specific safety standard names: "DO-178C", "ISO 26262", "ISO 14971", "IEC 62304", "FDA 21 CFR 820", "IEC 61508"
  * **Then** zero matches are found across all 6 files

#### Test Case: STP-005-B (HARDCODED commands cleaned of unconditional regulatory references)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Command Composition)
**Description**: Verify the 3 HARDCODED commands have had all unconditional regulatory references removed and replaced with domain-agnostic language.

* **System Scenario: STS-005-B1**
  * **Given** the refactored `commands/trace.md` base command file
  * **When** the file content is searched for "regulatory-grade", "DO-178C", "ISO 26262", "IEC 62304", "FDA 21 CFR 820", "IEC 61508"
  * **Then** zero matches are found in the Goal and Operating Constraints sections

* **System Scenario: STS-005-B2**
  * **Given** the refactored `commands/hazard-analysis.md` base command file
  * **When** the file's description line and severity table sections are inspected
  * **Then** the description contains no "ISO 14971" or "ISO 26262" references
  * **And** severity tables use generic terminology (not ASIL A–D or DAL A–E)

* **System Scenario: STS-005-B3**
  * **Given** the refactored `commands/peer-review.md` base command file
  * **When** the Governing Standard mapping table is inspected
  * **Then** the table lists only domain-agnostic standards: IEEE 1016, ISO 29119, ISO 29119-4, IEEE 42010, INCOSE
  * **And** no safety standard names (DO-178C, ISO 26262, ISO 14971) appear in the table

#### Test Case: STP-005-C (Standardized domain loading instruction replaces ad-hoc conditionals)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Command Composition)
**Description**: Verify all 9 refactored commands contain the standardized domain loading instruction block and no remnants of the old ad-hoc conditional patterns.

* **System Scenario: STS-005-C1**
  * **Given** the 9 refactored command files (6 MIXED + 3 HARDCODED)
  * **When** each file is searched for the standardized instruction pattern referencing `commands/overlays/{domain}/{command-name}.md`
  * **Then** each file contains exactly one standardized domain loading instruction block

* **System Scenario: STS-005-C2**
  * **Given** the 6 previously MIXED command files
  * **When** each file is searched for the old ad-hoc conditional pattern ("If `domain` is set in v-model-config.yml" followed by inline domain-specific content)
  * **Then** zero matches are found — no remnants of the old pattern exist

#### Test Case: STP-005-D (No scripts modified by refactoring)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify the refactoring modifies zero scripts — only Markdown content files are changed.

* **System Scenario: STS-005-D1**
  * **Given** the complete set of commits for the base command refactoring work
  * **When** the `git diff` is filtered to `scripts/`, `*.sh`, and `*.ps1` file paths
  * **Then** zero file changes are reported in script directories or script files

#### Test Case: STP-005-E (14 commands preserved — no additions or removals)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify the command count remains exactly 14 after refactoring — no commands added or removed.

* **System Scenario: STS-005-E1**
  * **Given** the `commands/` directory after refactoring (excluding the `overlays/` subdirectory)
  * **When** the `.md` files in `commands/` are counted
  * **Then** exactly 14 command files exist

---

### Component Verification: SYS-006 (Template Overlay Extraction Engine)

**Parent Requirements**: REQ-014, REQ-CN-001

#### Test Case: STP-006-A (Gating comments removed from all 7 GATED base templates)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Extracted Template Content)
**Description**: Verify all 7 GATED templates have had their `<!-- SAFETY-CRITICAL SECTION -->` (and equivalent) gating comments completely removed, leaving genuinely clean base templates.

* **System Scenario: STS-006-A1**
  * **Given** the 7 previously GATED base template files in `templates/`
  * **When** each file is searched for gating comment patterns: `<!-- SAFETY-CRITICAL SECTION -->`, `<!-- DOMAIN-SPECIFIC SCALES -->`, `<!-- SAFETY-CRITICAL TECHNIQUES -->`
  * **Then** zero matches are found across all 7 files
  * **And** the content inside the former gating blocks is no longer present in the base templates

#### Test Case: STP-006-B (Extracted content correctly placed in overlay template files)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Extracted Template Content)
**Description**: Verify the content that was inside gating comments now exists in the corresponding domain overlay template files.

* **System Scenario: STS-006-B1**
  * **Given** the `templates/system-design-template.md` at v0.5.0 contained a `<!-- SAFETY-CRITICAL SECTION -->` block with Freedom from Interference and Restricted Complexity tables
  * **When** the v0.6.0 `templates/overlays/iso_26262/system-design-overlay.md` is read
  * **Then** the overlay file contains the Freedom from Interference and Restricted Complexity table structures that were previously inside the gating block

* **System Scenario: STS-006-B2**
  * **Given** the `templates/hazard-analysis-template.md` at v0.5.0 contained a `<!-- DOMAIN-SPECIFIC SCALES -->` block with domain-specific severity scales
  * **When** the v0.6.0 `templates/overlays/iso_26262/hazard-analysis-overlay.md` is read
  * **Then** the overlay file contains the ISO 26262 ASIL severity scale that was previously inside the gating block

#### Test Case: STP-006-C (No scripts modified during template extraction)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify template extraction modifies zero scripts — only Markdown template files are changed.

* **System Scenario: STS-006-C1**
  * **Given** the complete set of commits for the template extraction work
  * **When** the `git diff` is filtered to `scripts/`, `*.sh`, and `*.ps1` file paths
  * **Then** zero file changes are reported

---

### Component Verification: SYS-007 (Domain Overlay Content Sets)

**Parent Requirements**: REQ-005, REQ-006, REQ-017, REQ-018, REQ-019, REQ-021, REQ-CN-005

#### Test Case: STP-007-A (iso_26262 overlay set completeness — minimum 9 commands)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Overlay Content Discovery)
**Description**: Verify the `iso_26262` domain overlay contains command overlay files for at minimum the 9 specified commands.

* **System Scenario: STS-007-A1**
  * **Given** the `commands/overlays/iso_26262/` directory
  * **When** the `.md` files (excluding `_domain.yml`) are listed
  * **Then** at minimum these files exist: `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`, `trace.md`, `hazard-analysis.md`, `peer-review.md`

#### Test Case: STP-007-B (do_178c overlay set completeness — minimum 6 commands)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Overlay Content Discovery)
**Description**: Verify the `do_178c` domain overlay contains command overlay files for at minimum the 6 specified commands.

* **System Scenario: STS-007-B1**
  * **Given** the `commands/overlays/do_178c/` directory
  * **When** the `.md` files (excluding `_domain.yml`) are listed
  * **Then** at minimum these files exist: `architecture-design.md`, `module-design.md`, `unit-test.md`, `trace.md`, `hazard-analysis.md`, `peer-review.md`

#### Test Case: STP-007-C (iec_62304 overlay set completeness — minimum 3 commands)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Overlay Content Discovery)
**Description**: Verify the `iec_62304` domain overlay contains command overlay files for at minimum the 3 specified commands.

* **System Scenario: STS-007-C1**
  * **Given** the `commands/overlays/iec_62304/` directory
  * **When** the `.md` files (excluding `_domain.yml`) are listed
  * **Then** at minimum these files exist: `hazard-analysis.md`, `trace.md`, `peer-review.md`

#### Test Case: STP-007-D (Exactly 3 domain overlay sets — no more, no less)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify exactly 3 domain overlay sets are created — the boundary condition of the feature scope.

* **System Scenario: STS-007-D1**
  * **Given** the `commands/overlays/` directory
  * **When** the subdirectories are counted
  * **Then** exactly 3 subdirectories exist: `iso_26262/`, `do_178c/`, `iec_62304/`

#### Test Case: STP-007-E (Overlay content uses preference-based indirection)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Overlay Content Discovery)
**Description**: Verify overlay command files use preference-based language rather than duplicating base command content.

* **System Scenario: STS-007-E1**
  * **Given** the overlay command file `commands/overlays/iso_26262/hazard-analysis.md`
  * **When** the file content is analyzed
  * **Then** the file contains preference-based language (e.g., "prefer", "use the domain's", "instead of the generic")
  * **And** the file does NOT contain a duplicate of the base `hazard-analysis.md` command's generation flow or structural instructions

#### Test Case: STP-007-F (Overlay composition is additive — base content unmodified)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verify that domain overlay content is appended AFTER base content and does not modify, override, or replace any base content.

* **System Scenario: STS-007-F1**
  * **Given** a project with `domain: iso_26262` configured and a `system-design` command invocation
  * **When** the effective command content is assembled (base + overlay)
  * **Then** the base content of `commands/system-design.md` appears first, intact and unmodified
  * **And** the overlay content of `commands/overlays/iso_26262/system-design.md` appears after the base content

* **System Scenario: STS-007-F2**
  * **Given** a project with no `domain` configured and the same `system-design` command invocation
  * **When** the effective command content is assembled
  * **Then** only the base content of `commands/system-design.md` is used — identical to the base portion in STS-007-F1

---

### Component Verification: SYS-008 (Extension Metadata Updater)

**Parent Requirements**: REQ-015, REQ-016

#### Test Case: STP-008-A (Command descriptions use domain-agnostic language)

**Technique**: Interface Contract Testing
**Target View**: Data Design View
**Description**: Verify the 9 previously contaminated command descriptions in `extension.yml` now use domain-agnostic language with no safety standard references.

* **System Scenario: STS-008-A1**
  * **Given** the `extension.yml` file at v0.6.0
  * **When** the `description` field of each of the 14 commands is searched for "DO-178C", "ISO 26262", "ISO 14971", "IEC 62304", "regulatory-grade"
  * **Then** zero matches are found across all 14 command descriptions

* **System Scenario: STS-008-A2**
  * **Given** the `extension.yml` file at v0.6.0
  * **When** each command description is read
  * **Then** each description preserves the command's functional purpose (e.g., "Generate a system design document" not "Generate a safety-compliant system design document")

#### Test Case: STP-008-B (safety-critical tag retained)

**Technique**: Boundary Value Analysis
**Target View**: Data Design View
**Description**: Verify the `safety-critical` tag remains present and unmodified in `extension.yml`.

* **System Scenario: STS-008-B1**
  * **Given** the `extension.yml` file at v0.6.0
  * **When** the `tags` section is parsed
  * **Then** the tag `safety-critical` is present in the list

---

### Component Verification: SYS-009 (Cross-Feature Lifecycle Coordinator)

**Parent Requirements**: REQ-LC-001, REQ-LC-002, REQ-LC-003, REQ-LC-004, REQ-LC-005

#### Test Case: STP-009-A (MIXED command parent features have MODIFIED annotations)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Lifecycle Annotations)
**Description**: Verify Features 002, 003, and 004 have their affected requirement and design IDs marked MODIFIED with the correct rationale after the 6 MIXED commands are refactored.

* **System Scenario: STS-009-A1**
  * **Given** the 6 MIXED commands have been refactored and Feature 002 owns system-design and system-test
  * **When** Feature 002's V-Model `requirements.md` is inspected
  * **Then** the requirement IDs that specified domain-specific system-design and system-test content are annotated with `[MODIFIED — Domain-specific content extracted to overlay per Feature 006a]`

* **System Scenario: STS-009-A2**
  * **Given** Feature 003 owns architecture-design and integration-test
  * **When** Feature 003's V-Model `requirements.md` is inspected
  * **Then** the affected requirement IDs are annotated with `[MODIFIED — Domain-specific content extracted to overlay per Feature 006a]`

#### Test Case: STP-009-B (HARDCODED command parent features have MODIFIED annotations)

**Technique**: Interface Contract Testing
**Target View**: Interface View (Lifecycle Annotations)
**Description**: Verify Features 001, 005a, and 005c have their affected IDs marked MODIFIED with the correct rationale after the 3 HARDCODED commands are refactored.

* **System Scenario: STS-009-B1**
  * **Given** `trace.md` (Feature 001) has been refactored to remove unconditional regulatory references
  * **When** Feature 001's V-Model artifacts are inspected
  * **Then** the affected IDs are annotated with `[MODIFIED — Unconditional domain-specific content removed from base and relocated to overlay per Feature 006a]`

* **System Scenario: STS-009-B2**
  * **Given** `peer-review.md` (Feature 005c) has been refactored to parameterize the governing standard table
  * **When** Feature 005c's V-Model artifacts are inspected
  * **Then** the affected IDs are annotated with `[MODIFIED — Unconditional domain-specific content removed from base and relocated to overlay per Feature 006a]`

#### Test Case: STP-009-C (SUSPECT cascade to downstream artifacts)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verify that after parent feature IDs are marked MODIFIED, downstream V-Model artifacts tracing to those IDs are marked SUSPECT until resolved.

* **System Scenario: STS-009-C1**
  * **Given** Feature 002's `requirements.md` has a requirement marked `[MODIFIED]`
  * **When** Feature 002's `acceptance-plan.md` is re-generated via the acceptance command
  * **Then** the acceptance test cases tracing to the MODIFIED requirement are marked `[SUSPECT — Parent {REQ-ID} modified]`

* **System Scenario: STS-009-C2**
  * **Given** a SUSPECT acceptance test case for Feature 002 whose parent requirement was MODIFIED solely due to domain content extraction (functional intent unchanged)
  * **When** the SUSPECT item is reviewed
  * **Then** the item is resolved as "confirmed still valid" without content changes because the base functional behavior has not changed

#### Test Case: STP-009-D (Lifecycle coordinator blocked when 006b unavailable)

**Technique**: Fault Injection
**Target View**: Dependency View
**Description**: Verify the lifecycle coordination process cannot proceed if Feature 006b's lifecycle model is not yet implemented.

* **System Scenario: STS-009-D1**
  * **Given** Feature 006b's lifecycle model is not yet implemented (no MODIFIED/SUSPECT annotation mechanism available in commands)
  * **When** the Cross-Feature Lifecycle Coordinator attempts to mark parent feature IDs as MODIFIED
  * **Then** the process is blocked and flagged: "Feature 006b lifecycle model required for cross-feature evolution"

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | 9 (9 active, 0 deprecated) |
| Total Test Cases (STP) | 32 (32 active, 0 deprecated, 0 suspect) |
| Total Scenarios (STS) | 49 |
| Components with ≥1 STP | 9 / 9 (100%) (active items only) |
| Test Cases with ≥1 STS | 32 / 32 (100%) |
| **Overall Coverage (SYS→STP)** | **100%** (active items only) |

### Technique Distribution

| Technique | Count |
|-----------|-------|
| Interface Contract Testing | 19 |
| Boundary Value Analysis | 8 |
| Equivalence Partitioning | 1 |
| Fault Injection | 4 |
| **Total** | **32** |

## Uncovered Components

None — full coverage achieved.
