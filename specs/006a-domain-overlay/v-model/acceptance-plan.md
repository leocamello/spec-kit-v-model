# Acceptance Test Plan: Domain Overlay Architecture


**Feature Branch**: `feature/006a-domain-overlay`
**Created**: 2025-07-19
**Status**: Draft
**Source**: `specs/006a-domain-overlay/v-model/requirements.md`

## Overview

This document defines the Acceptance Test Plan for the Domain Overlay Architecture feature. Every requirement in `requirements.md` has one or more Test Cases (ATP), and every Test Case has one or more executable User Scenarios (SCN) in BDD format (Given/When/Then). The plan covers the filesystem overlay structure for commands and templates, the `_domain.yml` manifest files, the `domain` field in `v-model-config.yml`, additive composition of overlay content, zero-config domain-agnostic defaults, graceful fallback when overlays are missing, refactoring of 9 contaminated commands (6 MIXED, 3 HARDCODED), extraction of 7 gated template sections, domain-agnostic extension.yml descriptions, three initial domain overlays (`iso_26262`, `do_178c`, `iec_62304`), standardized domain loading instructions, preference-based overlay indirection, cross-feature lifecycle evolution of parent feature specs, and all constraint enforcement.

## ID Schema

- **Test Case**: `ATP-{NNN}-{X}` — where NNN matches the parent REQ, X is a letter suffix (A, B, C...)
- **Scenario**: `SCN-{NNN}-{X}{#}` — nested under the parent ATP, with numeric suffix (1, 2, 3...)
- Example: `SCN-001-A1` → Scenario 1 of Test Case A validating REQ-001

## Acceptance Tests

### Requirement Validation: REQ-001 (Command Overlay Directory Structure)

#### Test Case: ATP-001-A (commands/overlays/ directory exists with domain subdirectories)
**Linked Requirement:** REQ-001
**Description:** Verify the extension provides a `commands/overlays/` directory where each subdirectory is named with a domain ID and contains command overlay files.
**Validation Condition:** Directory `commands/overlays/` exists, contains one subdirectory per supported domain, and each subdirectory contains `.md` overlay files.
**Expected Result:** `commands/overlays/iso_26262/`, `commands/overlays/do_178c/`, and `commands/overlays/iec_62304/` directories exist, each containing at least one `.md` command overlay file.

* **User Scenario: SCN-001-A1**
  * **Given** a fresh clone of the spec-kit-v-model extension repository at the v0.6.0 tag
  * **When** the user lists the contents of `commands/overlays/`
  * **Then** three subdirectories exist: `iso_26262/`, `do_178c/`, and `iec_62304/`
  * **And** each subdirectory contains at least one `.md` file

#### Test Case: ATP-001-B (Overlay file names match base command names)
**Linked Requirement:** REQ-001
**Description:** Verify that each overlay command file is named identically to its corresponding base command file, enabling predictable path resolution.
**Validation Condition:** Every `.md` file in a domain overlay directory has a matching base command file in `commands/`.
**Expected Result:** `commands/overlays/iso_26262/system-design.md` has a corresponding `commands/system-design.md` in the base directory.

* **User Scenario: SCN-001-B1**
  * **Given** a fresh clone of the spec-kit-v-model extension repository at the v0.6.0 tag
  * **When** the user lists all `.md` files in `commands/overlays/iso_26262/` excluding `_domain.yml`
  * **Then** every file name (e.g., `system-design.md`, `hazard-analysis.md`) has a matching file in the `commands/` base directory

---

### Requirement Validation: REQ-002 (Template Overlay Directory Structure)

#### Test Case: ATP-002-A (templates/overlays/ directory exists with domain subdirectories)
**Linked Requirement:** REQ-002
**Description:** Verify the extension provides a `templates/overlays/` directory where each subdirectory is named with a domain ID and contains template overlay files.
**Validation Condition:** Directory `templates/overlays/` exists, contains one subdirectory per supported domain, and each subdirectory contains `-overlay.md` files.
**Expected Result:** `templates/overlays/iso_26262/`, `templates/overlays/do_178c/`, and `templates/overlays/iec_62304/` directories exist, each containing at least one `-overlay.md` template file.

* **User Scenario: SCN-002-A1**
  * **Given** a fresh clone of the spec-kit-v-model extension repository at the v0.6.0 tag
  * **When** the user lists the contents of `templates/overlays/`
  * **Then** three subdirectories exist: `iso_26262/`, `do_178c/`, and `iec_62304/`
  * **And** each subdirectory contains at least one file with the `-overlay.md` suffix

---

### Requirement Validation: REQ-003 (Domain Manifest Files)

#### Test Case: ATP-003-A (Each domain directory contains a valid _domain.yml manifest)
**Linked Requirement:** REQ-003
**Description:** Verify each domain overlay directory contains a `_domain.yml` manifest file with all required metadata fields.
**Validation Condition:** `_domain.yml` exists in each domain directory and contains: display name, governing standards, classification system name, and commands list.
**Expected Result:** `commands/overlays/iso_26262/_domain.yml` contains `name: "ISO 26262"`, a `standards` list, a `classification` field (e.g., `ASIL`), and a `commands` list enumerating the overlay files present.

* **User Scenario: SCN-003-A1**
  * **Given** a fresh clone of the spec-kit-v-model extension repository at the v0.6.0 tag
  * **When** the user reads `commands/overlays/iso_26262/_domain.yml`
  * **Then** the file contains a `name` field with value "ISO 26262"
  * **And** a `standards` field listing at least "ISO 26262"
  * **And** a `classification` field with value "ASIL"
  * **And** a `commands` list that matches the `.md` files present in the same directory

* **User Scenario: SCN-003-A2**
  * **Given** a fresh clone of the spec-kit-v-model extension repository at the v0.6.0 tag
  * **When** the user reads `commands/overlays/do_178c/_domain.yml`
  * **Then** the file contains a `name` field with value "DO-178C"
  * **And** a `classification` field with value "DAL"
  * **And** a `commands` list that matches the `.md` files present in the same directory

#### Test Case: ATP-003-B (Manifest commands list matches actual overlay files)
**Linked Requirement:** REQ-003
**Description:** Verify the `commands` list in each `_domain.yml` exactly matches the command overlay files present in the same directory.
**Validation Condition:** No overlay file is missing from the manifest, and no manifest entry lacks a corresponding overlay file.
**Expected Result:** For `iso_26262`, the `commands` list includes exactly the command names that have `.md` files in `commands/overlays/iso_26262/`.

* **User Scenario: SCN-003-B1**
  * **Given** a fresh clone of the spec-kit-v-model extension repository at the v0.6.0 tag
  * **When** the user compares the `commands` list in `commands/overlays/iso_26262/_domain.yml` against the `.md` files in `commands/overlays/iso_26262/` (excluding `_domain.yml`)
  * **Then** every `.md` file has a corresponding entry in the `commands` list
  * **And** every entry in the `commands` list has a corresponding `.md` file

---

### Requirement Validation: REQ-004 (Config Template Domain Field)

#### Test Case: ATP-004-A (config-template.yml includes commented-out domain field)
**Linked Requirement:** REQ-004
**Description:** Verify `config-template.yml` includes a commented-out `domain` field with inline documentation listing supported values and the domain-agnostic default behavior.
**Validation Condition:** The file contains a commented `domain` line and documentation listing `iso_26262`, `do_178c`, `iec_62304`.
**Expected Result:** `config-template.yml` contains lines with `# domain:` and documentation text listing the three supported values and stating that omission activates domain-agnostic mode.

* **User Scenario: SCN-004-A1**
  * **Given** a fresh clone of the spec-kit-v-model extension repository at the v0.6.0 tag
  * **When** the user reads `config-template.yml`
  * **Then** the file contains a commented-out `domain` field (e.g., `# domain: iso_26262`)
  * **And** inline documentation listing `iso_26262`, `do_178c`, and `iec_62304` as supported values
  * **And** a statement that omitting or leaving empty activates domain-agnostic mode

---

### Requirement Validation: REQ-005 (Command Overlay Additive Composition)

#### Test Case: ATP-005-A (Overlay command content appended after base command when domain is set)
**Linked Requirement:** REQ-005
**Description:** Verify that when `domain` is set and an overlay file exists, the overlay content is appended after the base command instructions during execution.
**Validation Condition:** The effective command content seen by the LLM is the concatenation of base command followed by overlay command content.
**Expected Result:** Running `/speckit.v-model.system-design` with `domain: iso_26262` produces output that includes both the base system design guidance AND the ISO 26262-specific sections (e.g., Freedom from Interference, ASIL Decomposition).

* **User Scenario: SCN-005-A1**
  * **Given** a project with `v-model-config.yml` containing `domain: iso_26262` and a `system-design.md` base command and `commands/overlays/iso_26262/system-design.md` overlay file
  * **When** the user executes `/speckit.v-model.system-design`
  * **Then** the generated `system-design.md` artifact includes base system design content (IEEE 1016 views)
  * **And** the artifact also includes ISO 26262-specific sections (Freedom from Interference, ASIL classification)

#### Test Case: ATP-005-B (Overlay content does not replace base content)
**Linked Requirement:** REQ-005
**Description:** Verify the base command content is always present regardless of overlay activation — the overlay only adds content, never replaces.
**Validation Condition:** The base sections of the output are identical whether or not a domain overlay is active.
**Expected Result:** The IEEE 1016 design views section appears in the output both when `domain` is not set and when `domain: iso_26262` is set.

* **User Scenario: SCN-005-B1**
  * **Given** two projects: Project A with no `domain` field set, and Project B with `domain: iso_26262`
  * **When** the user executes `/speckit.v-model.system-design` in both projects
  * **Then** the base system design sections (decomposition view, dependency view, interface view, detail view) are present in both outputs
  * **And** Project B's output additionally contains ISO 26262-specific sections that are absent from Project A's output

---

### Requirement Validation: REQ-006 (Template Overlay Additive Composition)

#### Test Case: ATP-006-A (Overlay template content appended after base template when domain is set)
**Linked Requirement:** REQ-006
**Description:** Verify that when `domain` is set and a template overlay file exists, the overlay template content is appended after the base template content.
**Validation Condition:** The effective template used for artifact generation includes base template sections followed by overlay template sections.
**Expected Result:** The `system-design.md` artifact generated with `domain: iso_26262` includes the base template's section headings followed by additional domain-specific section headings from the overlay template.

* **User Scenario: SCN-006-A1**
  * **Given** a project with `v-model-config.yml` containing `domain: iso_26262` and both a base `system-design-template.md` and an overlay `templates/overlays/iso_26262/system-design-overlay.md`
  * **When** the user executes `/speckit.v-model.system-design`
  * **Then** the generated artifact follows the base template structure
  * **And** appends the overlay template's domain-specific sections after the base sections

---

### Requirement Validation: REQ-007 (Zero-Config Domain-Agnostic Default)

#### Test Case: ATP-007-A (No domain-specific content when domain is not set)
**Linked Requirement:** REQ-007
**Description:** Verify that when `domain` is not set, empty, or `v-model-config.yml` does not exist, every command produces output with zero domain-specific language.
**Validation Condition:** The output of every command contains no domain-specific terms (ASIL, DAL, MC/DC, MISRA, CERT-C, SIL/HIL, WCET, "regulatory-grade").
**Expected Result:** Running `/speckit.v-model.system-design` without a domain configured produces a clean system design artifact referencing only IEEE 1016 and containing no ASIL tables, no ISO 26262 references, and no safety-specific section headers.

* **User Scenario: SCN-007-A1**
  * **Given** a project with no `v-model-config.yml` file
  * **When** the user executes `/speckit.v-model.system-design`
  * **Then** the generated `system-design.md` contains no occurrences of "ASIL", "DAL", "MC/DC", "MISRA", "CERT-C", "SIL/HIL", "WCET", or "regulatory-grade"
  * **And** the artifact references only universally applicable standards (IEEE 1016)

* **User Scenario: SCN-007-A2**
  * **Given** a project with `v-model-config.yml` that has `domain:` set to an empty string
  * **When** the user executes `/speckit.v-model.unit-test`
  * **Then** the generated `unit-test.md` contains no occurrences of "MC/DC", "Variable-Level Fault Injection", "MISRA", or "CERT-C"

#### Test Case: ATP-007-B (No domain content when v-model-config.yml exists but domain field is absent)
**Linked Requirement:** REQ-007
**Description:** Verify that a `v-model-config.yml` without a `domain` field produces the same domain-agnostic behavior as having no config file at all.
**Validation Condition:** Output is identical to the no-config-file case.
**Expected Result:** Running `/speckit.v-model.hazard-analysis` with a `v-model-config.yml` that has no `domain` field produces general-purpose FMEA output with no ISO 14971 or ISO 26262 severity scales.

* **User Scenario: SCN-007-B1**
  * **Given** a project with `v-model-config.yml` containing project name and other fields but no `domain` field
  * **When** the user executes `/speckit.v-model.hazard-analysis`
  * **Then** the generated hazard analysis uses general-purpose FMEA framing
  * **And** contains no references to "ISO 14971", "ISO 26262", or domain-specific severity scales (ASIL, DAL)

---

### Requirement Validation: REQ-008 (Graceful Fallback for Missing Overlays)

#### Test Case: ATP-008-A (Missing overlay file does not generate error)
**Linked Requirement:** REQ-008
**Description:** Verify that when `domain` is set but no overlay file exists for a specific command, the base content is used without error.
**Validation Condition:** The command completes successfully using base content, with no error message, warning, or user-visible notification about the missing overlay.
**Expected Result:** Running `/speckit.v-model.requirements` with `domain: iso_26262` succeeds normally since `requirements.md` is CLEAN and has no overlay, producing the same output as without a domain.

* **User Scenario: SCN-008-A1**
  * **Given** a project with `v-model-config.yml` containing `domain: iso_26262` and a `commands/overlays/iso_26262/` directory that does NOT contain a `requirements.md` overlay
  * **When** the user executes `/speckit.v-model.requirements`
  * **Then** the command completes successfully
  * **And** the output contains no error, warning, or notification about a missing overlay
  * **And** the generated `requirements.md` is identical to what would be generated without a domain configured

---

### Requirement Validation: REQ-009 (MIXED Command Refactoring)

#### Test Case: ATP-009-A (Domain-specific content fully extracted from all 6 MIXED commands)
**Linked Requirement:** REQ-009
**Description:** Verify that all 6 MIXED commands have had their safety-standard references, domain-specific section headers, and domain-specific table columns extracted from the base file.
**Validation Condition:** Each base command file contains zero domain-specific terms after refactoring.
**Expected Result:** `commands/system-design.md` base file contains no "ASIL", "Freedom from Interference (ISO 26262-6 §7.4.8)", or other domain-specific section headers.

* **User Scenario: SCN-009-A1**
  * **Given** the refactored `commands/system-design.md` base command file
  * **When** the user searches the file for domain-specific terms (ASIL, DAL, MC/DC, MISRA, CERT-C, SIL/HIL, WCET, "Freedom from Interference", "ASIL Decomposition")
  * **Then** zero matches are found

* **User Scenario: SCN-009-A2**
  * **Given** the refactored `commands/module-design.md` base command file
  * **When** the user searches the file for "DO-178C", "ISO 26262", "MISRA", "CERT-C", "Single Entry/Exit"
  * **Then** zero matches are found
  * **And** the file's description line contains no domain-specific standard names

#### Test Case: ATP-009-B (Extracted content placed in domain overlay files)
**Linked Requirement:** REQ-009
**Description:** Verify the domain-specific content extracted from each MIXED command exists in the appropriate domain overlay files.
**Validation Condition:** Domain content that was in the base command is now present in the overlay file.
**Expected Result:** `commands/overlays/iso_26262/system-design.md` contains "Freedom from Interference" and ASIL-related content that was previously in the base `system-design.md`.

* **User Scenario: SCN-009-B1**
  * **Given** the overlay file `commands/overlays/iso_26262/system-design.md`
  * **When** the user reads the file content
  * **Then** the file contains ISO 26262-specific content including "Freedom from Interference" and "ASIL" references
  * **And** this content was previously present in the base `commands/system-design.md` (verifiable via `git diff` against v0.5.0)

---

### Requirement Validation: REQ-010 (trace.md HARDCODED Cleanup)

#### Test Case: ATP-010-A (Base trace.md free of regulatory language)
**Linked Requirement:** REQ-010
**Description:** Verify the base `trace.md` has "regulatory-grade" replaced with domain-agnostic language and all 5 unconditional safety standard references removed.
**Validation Condition:** The base file contains zero occurrences of "regulatory-grade", "DO-178C", "ISO 26262", "IEC 62304", "FDA 21 CFR 820", and "IEC 61508".
**Expected Result:** `commands/trace.md` describes traceability using domain-agnostic language with no safety standard names in the Goal or Operating Constraints sections.

* **User Scenario: SCN-010-A1**
  * **Given** the refactored `commands/trace.md` base command file
  * **When** the user searches for "regulatory-grade", "DO-178C", "ISO 26262", "IEC 62304", "FDA 21 CFR 820", "IEC 61508"
  * **Then** zero matches are found in the file

#### Test Case: ATP-010-B (Regulatory compliance framing exists in overlay)
**Linked Requirement:** REQ-010
**Description:** Verify a domain overlay exists for trace.md containing the regulatory compliance framing removed from the base.
**Validation Condition:** At least one domain overlay contains the regulatory standard references that were removed from the base trace.md.
**Expected Result:** `commands/overlays/iso_26262/trace.md` contains ISO 26262 traceability compliance framing.

* **User Scenario: SCN-010-B1**
  * **Given** the overlay file `commands/overlays/iso_26262/trace.md`
  * **When** the user reads the file content
  * **Then** the file contains ISO 26262-specific traceability compliance framing including "ISO 26262" references

---

### Requirement Validation: REQ-011 (hazard-analysis.md HARDCODED Cleanup)

#### Test Case: ATP-011-A (Base hazard-analysis.md uses general-purpose FMEA framing)
**Linked Requirement:** REQ-011
**Description:** Verify the base `hazard-analysis.md` has "ISO 14971/ISO 26262-compliant" removed from its description and domain-specific severity scales moved to overlays, with general-purpose FMEA framing retained.
**Validation Condition:** Base file description does not reference ISO 14971 or ISO 26262; severity tables use generic scales, not domain-specific ones.
**Expected Result:** `commands/hazard-analysis.md` describes hazard analysis as a general-purpose FMEA methodology with a generic severity scale (e.g., Catastrophic/Critical/Marginal/Negligible without tying to ASIL or DAL).

* **User Scenario: SCN-011-A1**
  * **Given** the refactored `commands/hazard-analysis.md` base command file
  * **When** the user reads the file's description and severity table sections
  * **Then** the description contains no "ISO 14971" or "ISO 26262" references
  * **And** the severity scales use generic terminology, not ASIL (A–D) or DAL (A–E) classifications

#### Test Case: ATP-011-B (Domain-specific severity scales in overlay files)
**Linked Requirement:** REQ-011
**Description:** Verify the domain-specific severity scales (ISO 26262 ASIL, DO-178C Failure Conditions) exist in their respective overlay files.
**Validation Condition:** Each domain overlay for hazard-analysis contains the domain's severity classification system.
**Expected Result:** `commands/overlays/iso_26262/hazard-analysis.md` contains ASIL (A–D) severity scale; `commands/overlays/do_178c/hazard-analysis.md` contains DAL (A–E) / Failure Condition severity scale.

* **User Scenario: SCN-011-B1**
  * **Given** the overlay file `commands/overlays/iso_26262/hazard-analysis.md`
  * **When** the user reads the severity scale section
  * **Then** the file contains the ISO 26262 ASIL classification (A, B, C, D) and associated severity definitions

---

### Requirement Validation: REQ-012 (peer-review.md HARDCODED Cleanup)

#### Test Case: ATP-012-A (Base peer-review.md uses domain-agnostic governing standards)
**Linked Requirement:** REQ-012
**Description:** Verify the base `peer-review.md` uses domain-agnostic standards (IEEE 1016, ISO 29119, INCOSE) as defaults in the Governing Standard mapping table.
**Validation Condition:** The mapping table in the base file references only universally applicable standards; no safety standard names appear unconditionally.
**Expected Result:** The Governing Standard mapping table in `commands/peer-review.md` lists IEEE 1016 for system-design, ISO 29119 for test artifacts, and INCOSE for requirements — not DO-178C, ISO 26262, or ISO 14971.

* **User Scenario: SCN-012-A1**
  * **Given** the refactored `commands/peer-review.md` base command file
  * **When** the user reads the Governing Standard mapping table
  * **Then** the table lists only domain-agnostic standards: IEEE 1016, ISO 29119, ISO 29119-4, IEEE 42010, INCOSE
  * **And** the table does not list DO-178C, ISO 26262, or ISO 14971

---

### Requirement Validation: REQ-013 (Base Command Cleanliness)

#### Test Case: ATP-013-A (No domain-specific terms in any base command)
**Linked Requirement:** REQ-013
**Description:** Verify that after refactoring, every base command file references only universally applicable standards and contains none of the banned domain-specific terms.
**Validation Condition:** A comprehensive text search of all 14 base command files returns zero matches for the banned term list.
**Expected Result:** `grep -rn` for ASIL, DAL, SIL, HIL, MC/DC, WCET, MISRA, CERT-C, "regulatory-grade" across all files in `commands/` (excluding `commands/overlays/`) returns zero matches.

* **User Scenario: SCN-013-A1**
  * **Given** all 14 base command files in `commands/` (excluding subdirectories)
  * **When** the user searches all files for the terms: ASIL, DAL, SIL, HIL, MC/DC, WCET, MISRA, CERT-C, "regulatory-grade"
  * **Then** zero matches are found across all 14 files

* **User Scenario: SCN-013-A2**
  * **Given** all 14 base command files in `commands/` (excluding subdirectories)
  * **When** the user searches all files for standard names: "DO-178C", "ISO 26262", "ISO 14971", "IEC 62304", "FDA 21 CFR 820", "IEC 61508"
  * **Then** zero matches are found across all 14 files
  * **And** references to universally applicable standards (IEEE 1016, ISO 29119, IEEE 42010, INCOSE) remain present in applicable commands

---

### Requirement Validation: REQ-014 (GATED Template Content Extraction)

#### Test Case: ATP-014-A (Gated content removed from base templates)
**Linked Requirement:** REQ-014
**Description:** Verify all 7 GATED templates have had their `<!-- SAFETY-CRITICAL SECTION -->` content extracted, leaving no commented-out safety sections in the base template.
**Validation Condition:** The base template files contain zero occurrences of `<!-- SAFETY-CRITICAL SECTION -->`, `<!-- DOMAIN-SPECIFIC SCALES -->`, or `<!-- SAFETY-CRITICAL TECHNIQUES -->`.
**Expected Result:** `templates/system-design-template.md` contains no HTML comment blocks related to safety-critical content.

* **User Scenario: SCN-014-A1**
  * **Given** all 7 previously GATED base template files in `templates/`
  * **When** the user searches for `<!-- SAFETY-CRITICAL SECTION -->`, `<!-- DOMAIN-SPECIFIC SCALES -->`, and `<!-- SAFETY-CRITICAL TECHNIQUES -->`
  * **Then** zero matches are found in any base template file

#### Test Case: ATP-014-B (Extracted gated content exists in overlay templates)
**Linked Requirement:** REQ-014
**Description:** Verify the content that was inside the gating comments now exists in the corresponding domain overlay template files.
**Validation Condition:** Domain overlay template files contain the sections that were previously gated in the base templates.
**Expected Result:** `templates/overlays/iso_26262/system-design-overlay.md` contains the safety-critical section content that was previously inside `<!-- SAFETY-CRITICAL SECTION -->` in `templates/system-design-template.md`.

* **User Scenario: SCN-014-B1**
  * **Given** the overlay template `templates/overlays/iso_26262/system-design-overlay.md`
  * **When** the user reads the file content
  * **Then** the file contains the system design safety sections (Freedom from Interference, ASIL classification) that were previously gated in the base template

---

### Requirement Validation: REQ-015 (Extension.yml Domain-Agnostic Descriptions)

#### Test Case: ATP-015-A (Command descriptions updated to domain-agnostic language)
**Linked Requirement:** REQ-015
**Description:** Verify the 9 command descriptions in `extension.yml` that previously referenced safety standards unconditionally now use domain-agnostic language.
**Validation Condition:** No command description in `extension.yml` contains safety standard names (DO-178C, ISO 26262, ISO 14971) or the term "regulatory-grade".
**Expected Result:** Each command description describes its function generically (e.g., "Generate a system design document following IEEE 1016") without assuming a safety-critical context.

* **User Scenario: SCN-015-A1**
  * **Given** the `extension.yml` file at v0.6.0
  * **When** the user reads the `description` field of each of the 14 commands
  * **Then** no description contains "DO-178C", "ISO 26262", "ISO 14971", "IEC 62304", or "regulatory-grade"
  * **And** each description preserves the command's functional purpose using domain-agnostic language

---

### Requirement Validation: REQ-016 (Safety-Critical Tag Retained)

#### Test Case: ATP-016-A (safety-critical tag present in extension.yml)
**Linked Requirement:** REQ-016
**Description:** Verify the `safety-critical` tag remains in `extension.yml` without modification.
**Validation Condition:** The `tags` section of `extension.yml` contains `safety-critical`.
**Expected Result:** `extension.yml` contains `safety-critical` in its tags list.

* **User Scenario: SCN-016-A1**
  * **Given** the `extension.yml` file at v0.6.0
  * **When** the user reads the `tags` section
  * **Then** the tag `safety-critical` is present in the list

---

### Requirement Validation: REQ-017 (ISO 26262 Domain Overlay Completeness)

#### Test Case: ATP-017-A (iso_26262 overlay covers all required commands)
**Linked Requirement:** REQ-017
**Description:** Verify the `iso_26262` domain overlay contains command and template overlay files for all commands where ISO 26262-specific content was extracted.
**Validation Condition:** Command overlays exist in `commands/overlays/iso_26262/` for at minimum: system-design, system-test, architecture-design, integration-test, module-design, unit-test, trace, hazard-analysis, and peer-review.
**Expected Result:** 9 command overlay files exist in `commands/overlays/iso_26262/`.

* **User Scenario: SCN-017-A1**
  * **Given** a fresh clone of the spec-kit-v-model extension repository at the v0.6.0 tag
  * **When** the user lists all `.md` files in `commands/overlays/iso_26262/` (excluding `_domain.yml`)
  * **Then** at minimum the following files exist: `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`, `trace.md`, `hazard-analysis.md`, `peer-review.md`

---

### Requirement Validation: REQ-018 (DO-178C Domain Overlay Completeness)

#### Test Case: ATP-018-A (do_178c overlay covers all required commands)
**Linked Requirement:** REQ-018
**Description:** Verify the `do_178c` domain overlay contains command and template overlay files for all commands where DO-178C-specific content was extracted.
**Validation Condition:** Command overlays exist in `commands/overlays/do_178c/` for at minimum: architecture-design, module-design, unit-test, trace, hazard-analysis, and peer-review.
**Expected Result:** At least 6 command overlay files exist in `commands/overlays/do_178c/`.

* **User Scenario: SCN-018-A1**
  * **Given** a fresh clone of the spec-kit-v-model extension repository at the v0.6.0 tag
  * **When** the user lists all `.md` files in `commands/overlays/do_178c/` (excluding `_domain.yml`)
  * **Then** at minimum the following files exist: `architecture-design.md`, `module-design.md`, `unit-test.md`, `trace.md`, `hazard-analysis.md`, `peer-review.md`

---

### Requirement Validation: REQ-019 (IEC 62304 Domain Overlay Completeness)

#### Test Case: ATP-019-A (iec_62304 overlay covers all required commands)
**Linked Requirement:** REQ-019
**Description:** Verify the `iec_62304` domain overlay contains command and template overlay files for all commands where IEC 62304-specific content was extracted.
**Validation Condition:** Command overlays exist in `commands/overlays/iec_62304/` for at minimum: hazard-analysis, trace, and peer-review.
**Expected Result:** At least 3 command overlay files exist in `commands/overlays/iec_62304/`.

* **User Scenario: SCN-019-A1**
  * **Given** a fresh clone of the spec-kit-v-model extension repository at the v0.6.0 tag
  * **When** the user lists all `.md` files in `commands/overlays/iec_62304/` (excluding `_domain.yml`)
  * **Then** at minimum the following files exist: `hazard-analysis.md`, `trace.md`, `peer-review.md`

---

### Requirement Validation: REQ-020 (Standardized Domain Loading Instruction)

#### Test Case: ATP-020-A (All overlay-capable commands use standardized domain loading block)
**Linked Requirement:** REQ-020
**Description:** Verify every command that supports domain overlay enrichment includes the standardized domain loading instruction block and that no ad-hoc conditional patterns remain.
**Validation Condition:** Each of the 9 refactored commands contains the standardized instruction and no command contains the old ad-hoc pattern.
**Expected Result:** `commands/system-design.md` contains the standardized instruction: "Load v-model-config.yml. If `domain` is set and an overlay exists at `commands/overlays/{domain}/system-design.md`, append its content after these base instructions."

* **User Scenario: SCN-020-A1**
  * **Given** the 9 refactored command files (6 MIXED + 3 HARDCODED)
  * **When** the user searches each file for the standardized domain loading instruction pattern
  * **Then** each file contains the standardized instruction block referencing `commands/overlays/{domain}/{command-name}.md`
  * **And** no file contains the old ad-hoc conditional pattern ("If `domain` is set in v-model-config.yml" followed by domain-specific inline content)

---

### Requirement Validation: REQ-021 (Preference-Based Overlay Indirection)

#### Test Case: ATP-021-A (Overlay content uses preference-based language)
**Linked Requirement:** REQ-021
**Description:** Verify overlay command files use preference-based indirection rather than duplicating base command content.
**Validation Condition:** Overlay files contain language like "prefer", "use the domain's", "replace the base" rather than verbatim copies of base command instructions.
**Expected Result:** `commands/overlays/iso_26262/system-design.md` contains instructions like "prefer the ISO 26262 safety integrity levels over the general-purpose severity scale" rather than re-specifying the entire system design generation flow.

* **User Scenario: SCN-021-A1**
  * **Given** the overlay command file `commands/overlays/iso_26262/hazard-analysis.md`
  * **When** the user reads the overlay content
  * **Then** the file uses preference-based language (e.g., "prefer the domain's severity scale", "use ASIL classification instead of the generic scale")
  * **And** the file does NOT duplicate the base `hazard-analysis.md` command's generation flow or structural instructions

---

### Requirement Validation: REQ-LC-001 (Lifecycle Evolution of Parent Feature Specs)

#### Test Case: ATP-LC-001-A (Refactored commands trigger lifecycle evolution in parent features)
**Linked Requirement:** REQ-LC-001
**Description:** Verify that when a base command is refactored to extract domain-specific content, the parent feature's V-Model artifacts are evolved using the ID lifecycle model: MODIFIED items are annotated, and downstream artifacts are marked SUSPECT.
**Validation Condition:** Parent feature requirement IDs whose content changed are annotated `[MODIFIED]` and their downstream artifacts contain `[SUSPECT]` annotations.
**Expected Result:** After refactoring `system-design.md`, the parent Feature 002's requirements specification has the relevant REQ marked `[MODIFIED — Domain-specific content extracted to overlay per Feature 006a]`.

* **User Scenario: SCN-LC-001-A1**
  * **Given** the `system-design.md` command has been refactored to extract ISO 26262-specific content to overlays
  * **When** the parent Feature 002's V-Model artifacts are evolved per the 006b lifecycle protocol
  * **Then** the requirement(s) in Feature 002's `requirements.md` that specified the domain-specific system design content are annotated with `[MODIFIED — Domain-specific content extracted to overlay per Feature 006a]`
  * **And** the downstream artifacts (acceptance plan, system test plan) that trace to those requirements contain `[SUSPECT]` annotations

---

### Requirement Validation: REQ-LC-002 (MIXED Command Parent Feature Evolution)

#### Test Case: ATP-LC-002-A (Features 002, 003, 004 specs have MODIFIED annotations for MIXED commands)
**Linked Requirement:** REQ-LC-002
**Description:** Verify the parent feature specs for all 6 MIXED commands have their affected requirement and design IDs marked MODIFIED with the specified rationale.
**Validation Condition:** Each affected parent feature's `requirements.md` contains MODIFIED annotations on the relevant IDs.
**Expected Result:** Feature 002's `requirements.md` has IDs related to system-design and system-test domain content marked `[MODIFIED — Domain-specific content extracted to overlay per Feature 006a]`.

* **User Scenario: SCN-LC-002-A1**
  * **Given** the 6 MIXED commands have been refactored (system-design, system-test from Feature 002; architecture-design, integration-test from Feature 003; module-design, unit-test from Feature 004)
  * **When** the user reads the `requirements.md` files for Features 002, 003, and 004
  * **Then** each file contains `[MODIFIED — Domain-specific content extracted to overlay per Feature 006a]` annotations on the requirement IDs that specified domain-specific content for the respective commands

---

### Requirement Validation: REQ-LC-003 (HARDCODED Command Parent Feature Evolution)

#### Test Case: ATP-LC-003-A (Features 001, 005a, 005c specs have MODIFIED annotations for HARDCODED commands)
**Linked Requirement:** REQ-LC-003
**Description:** Verify the parent feature specs for all 3 HARDCODED commands have their affected IDs marked MODIFIED with the specified rationale.
**Validation Condition:** Feature 001, 005a, and 005c requirement files contain MODIFIED annotations on the relevant IDs.
**Expected Result:** Feature 001's `requirements.md` has IDs related to trace.md domain content marked `[MODIFIED — Unconditional domain-specific content removed from base and relocated to overlay per Feature 006a]`.

* **User Scenario: SCN-LC-003-A1**
  * **Given** the 3 HARDCODED commands have been refactored (trace from Feature 001, hazard-analysis from Feature 005a, peer-review from Feature 005c)
  * **When** the user reads the `requirements.md` files for Features 001, 005a, and 005c
  * **Then** each file contains `[MODIFIED — Unconditional domain-specific content removed from base and relocated to overlay per Feature 006a]` annotations on the relevant requirement IDs

---

### Requirement Validation: REQ-LC-004 (Suspect Cascade to Downstream V-Model Artifacts)

#### Test Case: ATP-LC-004-A (Downstream artifacts marked SUSPECT after parent MODIFIED)
**Linked Requirement:** REQ-LC-004
**Description:** Verify that after marking parent feature IDs as MODIFIED, all downstream V-Model artifacts tracing to those IDs are marked SUSPECT and resolved through re-running V-Model commands.
**Validation Condition:** Each downstream artifact that traces to a MODIFIED ID contains a SUSPECT annotation that is eventually resolved (confirmed, updated, or deprecated).
**Expected Result:** After Feature 002's REQ for system-design domain content is marked MODIFIED, Feature 002's acceptance-plan.md shows the corresponding ATP marked `[SUSPECT — Parent {REQ-ID} modified]`, and after resolution the SUSPECT annotation is removed.

* **User Scenario: SCN-LC-004-A1**
  * **Given** Feature 002's `requirements.md` has a requirement marked `[MODIFIED — Domain-specific content extracted to overlay per Feature 006a]`
  * **When** the `/speckit.v-model.acceptance` command is re-run for Feature 002
  * **Then** the acceptance plan marks the corresponding ATP(s) as `[SUSPECT — Parent {REQ-ID} modified]`
  * **And** after review and resolution, the SUSPECT annotations are either removed (confirmed valid) or the ATPs are updated to reflect the new base-only content

---

### Requirement Validation: REQ-LC-005 (Confirm-Valid Resolution for Extraction-Only Changes)

#### Test Case: ATP-LC-005-A (Suspect items confirmable as valid when functional intent unchanged)
**Linked Requirement:** REQ-LC-005
**Description:** Verify that when a parent item is marked MODIFIED solely due to domain content extraction (not functional intent change), SUSPECT downstream items may be resolved by confirming them as still valid without content changes.
**Validation Condition:** The resolution process allows "confirm still valid" as a valid resolution type for SUSPECT items whose functional behavior has not changed.
**Expected Result:** A system-test ATP that tests "the system design decomposes requirements into components" remains valid after the parent system-design REQ is MODIFIED only to remove ASIL tables — the functional decomposition behavior is unchanged.

* **User Scenario: SCN-LC-005-A1**
  * **Given** Feature 002's system-design REQ is marked `[MODIFIED]` solely because ASIL Decomposition content was extracted to an overlay, with the base functional behavior (IEEE 1016 design views) unchanged
  * **And** Feature 002's system-test has an STP that validates "the system design includes all 4 IEEE 1016 views"
  * **When** the STP is marked `[SUSPECT — Parent {REQ-ID} modified]` and reviewed
  * **Then** the STP is resolved as "confirmed still valid" without content changes because the base functional behavior tested by the STP has not changed

---

### Requirement Validation: REQ-NF-001 (Base Immutability)

#### Test Case: ATP-NF-001-A (Domain selection does not alter base output)
**Linked Requirement:** REQ-NF-001
**Description:** Verify the base content produced by any command is identical whether or not `domain` is configured — domain selection is purely additive.
**Validation Condition:** Comparing the base sections of output generated with and without a domain yields zero differences.
**Expected Result:** The base system design sections (decomposition view, dependency view, interface view, detail view) are character-identical in output from `domain: iso_26262` vs. no domain.

* **User Scenario: SCN-NF-001-A1**
  * **Given** two identical projects: Project A with no `domain` configured, Project B with `domain: iso_26262`
  * **When** the user executes `/speckit.v-model.system-design` in both projects with identical input specifications
  * **Then** the base sections of both outputs (everything before the overlay content in Project B) are identical

---

### Requirement Validation: REQ-NF-002 (Domain ID Naming Convention)

#### Test Case: ATP-NF-002-A (Domain IDs consistently use snake_case)
**Linked Requirement:** REQ-NF-002
**Description:** Verify domain IDs use snake_case format consistently across directory names, `_domain.yml` references, and the config field.
**Validation Condition:** All references to domain IDs use snake_case (lowercase with underscores).
**Expected Result:** The domain is referred to as `iso_26262` (not `ISO26262`, `iso-26262`, or `ISO_26262`) in directory names, `_domain.yml` files, `config-template.yml`, and all command files.

* **User Scenario: SCN-NF-002-A1**
  * **Given** the complete set of overlay directories, `_domain.yml` files, and `config-template.yml`
  * **When** the user checks all domain ID references across directory names, YAML files, and command instruction blocks
  * **Then** every reference uses snake_case format: `iso_26262`, `do_178c`, `iec_62304`
  * **And** no reference uses alternative casing (e.g., `ISO26262`, `iso-26262`, `DO178C`)

---

### Requirement Validation: REQ-CN-001 (No Script Changes)

#### Test Case: ATP-CN-001-A (No scripts modified, added, or removed)
**Linked Requirement:** REQ-CN-001
**Description:** Verify this feature does not modify, add, or remove any scripts (Bash or PowerShell), validation logic, or CLI flags.
**Validation Condition:** `git diff v0.5.0..v0.6.0 -- scripts/` and `git diff v0.5.0..v0.6.0 -- *.sh *.ps1` show zero changes.
**Expected Result:** The `scripts/` directory is identical between v0.5.0 and v0.6.0 (for this feature's commits).

* **User Scenario: SCN-CN-001-A1**
  * **Given** the complete set of commits for Feature 006a
  * **When** the user runs `git diff` between the pre-006a state and post-006a state, filtered to `scripts/`, `*.sh`, and `*.ps1` files
  * **Then** zero file changes are reported

---

### Requirement Validation: REQ-CN-002 (No Command Addition or Removal)

#### Test Case: ATP-CN-002-A (14 commands remain unchanged in count)
**Linked Requirement:** REQ-CN-002
**Description:** Verify no commands are added or removed — the 14 existing commands remain.
**Validation Condition:** `commands/` contains exactly 14 `.md` files (excluding the `overlays/` subdirectory) and `extension.yml` lists exactly 14 commands.
**Expected Result:** `ls commands/*.md | wc -l` returns 14.

* **User Scenario: SCN-CN-002-A1**
  * **Given** the spec-kit-v-model extension at v0.6.0
  * **When** the user counts `.md` files in `commands/` (excluding the `overlays/` subdirectory)
  * **Then** exactly 14 command files exist
  * **And** `extension.yml` lists exactly 14 command entries

#### Test Case: ATP-CN-002-B (hazard-analysis available without domain)
**Linked Requirement:** REQ-CN-002
**Description:** Verify `hazard-analysis` remains available and functional without a domain configured, using general-purpose FMEA framing.
**Validation Condition:** Running `/speckit.v-model.hazard-analysis` without a domain produces a valid hazard analysis artifact.
**Expected Result:** The command completes successfully, producing a hazard analysis with general-purpose FMEA methodology and generic severity scales.

* **User Scenario: SCN-CN-002-B1**
  * **Given** a project with no `domain` configured in `v-model-config.yml`
  * **When** the user executes `/speckit.v-model.hazard-analysis`
  * **Then** the command completes successfully
  * **And** the generated artifact uses general-purpose FMEA framing with generic severity scales (not ASIL or DAL)

---

### Requirement Validation: REQ-CN-003 (Single Domain Only)

#### Test Case: ATP-CN-003-A (Only one domain active at a time)
**Linked Requirement:** REQ-CN-003
**Description:** Verify a project supports only one active domain at a time via the single `domain` field.
**Validation Condition:** The `domain` field in `v-model-config.yml` accepts exactly one value, not a list.
**Expected Result:** Setting `domain: iso_26262` activates ISO 26262 overlays exclusively; there is no syntax for specifying multiple domains.

* **User Scenario: SCN-CN-003-A1**
  * **Given** a project with `v-model-config.yml` containing `domain: iso_26262`
  * **When** the user executes `/speckit.v-model.system-design`
  * **Then** only ISO 26262 overlay content is appended
  * **And** no DO-178C or IEC 62304 overlay content appears in the output

---

### Requirement Validation: REQ-CN-004 (No Auto-Detection)

#### Test Case: ATP-CN-004-A (Domain requires manual configuration)
**Linked Requirement:** REQ-CN-004
**Description:** Verify the domain must be manually set in `v-model-config.yml` — there is no auto-detection from project content, repository metadata, or file analysis.
**Validation Condition:** A project containing ISO 26262-related file names or content but with no `domain` field in config produces domain-agnostic output.
**Expected Result:** Even if a repository contains files named `asil-analysis.md` or content mentioning "ISO 26262", the command output remains domain-agnostic unless `domain: iso_26262` is explicitly set in `v-model-config.yml`.

* **User Scenario: SCN-CN-004-A1**
  * **Given** a project with files containing "ISO 26262" and "ASIL" in their content, but `v-model-config.yml` has no `domain` field
  * **When** the user executes `/speckit.v-model.system-design`
  * **Then** the generated system design is domain-agnostic
  * **And** no ISO 26262 overlay content is included despite the project's content

---

### Requirement Validation: REQ-CN-005 (Three Domains Only)

#### Test Case: ATP-CN-005-A (Exactly three domain overlays created)
**Linked Requirement:** REQ-CN-005
**Description:** Verify only three domain overlays are created: `iso_26262`, `do_178c`, and `iec_62304`.
**Validation Condition:** `commands/overlays/` contains exactly 3 subdirectories.
**Expected Result:** `ls commands/overlays/` lists exactly: `do_178c/`, `iec_62304/`, `iso_26262/`.

* **User Scenario: SCN-CN-005-A1**
  * **Given** a fresh clone of the spec-kit-v-model extension repository at the v0.6.0 tag
  * **When** the user lists the subdirectories of `commands/overlays/`
  * **Then** exactly three directories exist: `do_178c/`, `iec_62304/`, `iso_26262/`

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Requirements (REQ) | 33 (33 active, 0 deprecated) |
| Total Test Cases (ATP) | 42 (42 active, 0 deprecated, 0 suspect) |
| Total Scenarios (SCN) | 46 |
| Active Requirements with ≥1 ATP | 33 / 33 (100%) |
| Test Cases with ≥1 SCN | 42 / 42 (100%) |
| **Overall Coverage** | **100%** (active items only) |

## Uncovered Requirements

None — full coverage achieved.

---

**Validation Status**: ✅ Full Coverage
**Generated**: 2025-07-19
**Validated by**: Manual count (deterministic validation script not applicable to content-only feature)
