# V-Model Requirements Specification: Impact Analysis

**Feature Branch**: `005b-impact-analysis`
**Created**: 2026-04-14
**Status**: Approved
**Source**: `specs/005b-impact-analysis/spec.md`

## Overview

This document formalizes the requirements for adding an `/speckit.v-model.impact-analysis` command to the V-Model Extension Pack. The command performs deterministic, bidirectional traversal of the V-Model ID graph to produce an impact report showing the "blast radius" of a changed artifact. Given one or more changed IDs, the script traces through all V-Model markdown files and identifies every artifact that is directly or transitively affected. Three traversal modes are supported: `--downward` (default, traces from a changed ID to all downstream dependents), `--upward` (traces from a changed ID to all upstream parents), and `--full` (combines both directions). The command is purely script-based (no AI generation) — it relies on regex-based parsing of existing V-Model artifacts to build and traverse the ID dependency graph. All requirements are atomized from the feature specification using the strict translator constraint.

## Requirements

### Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-001 | The extension SHALL provide an `impact-analysis.sh` Bash script that accepts one or more V-Model IDs and a V-Model directory path, and produces an impact report identifying all affected artifacts. | P1 | Core capability: deterministic blast-radius analysis is the primary deliverable. | Test |
| REQ-002 | The `impact-analysis.sh` script SHALL support a `--downward` flag (default when no direction flag is specified) that traces from the given ID(s) to all downstream artifacts that depend on them. | P1 | Downward traversal answers: "if I change this requirement, what tests and designs are affected?" | Test |
| REQ-003 | The `impact-analysis.sh` script SHALL support an `--upward` flag that traces from the given ID(s) to all upstream artifacts that the given IDs depend on or are derived from. | P1 | Upward traversal answers: "if this module changes, which requirements are affected?" | Test |
| REQ-004 | The `impact-analysis.sh` script SHALL support a `--full` flag that combines both downward and upward traversal from the given ID(s), producing the complete blast radius in both directions. | P1 | Full traversal provides the complete picture for complex change assessments. | Test |
| REQ-005 | The downward traversal SHALL follow the V-Model ID dependency chain: REQ → {ATP, SCN, SYS, HAZ} → {STP, STS, ARCH} → {ITP, ITS, MOD} → {UTP, UTS}. For each level, the script SHALL identify all IDs that reference the changed ID or any ID already in the suspect set. | P1 | The V-Model defines a strict hierarchy; downward traversal must follow this hierarchy to find all transitive dependents. | Test |
| REQ-006 | The upward traversal SHALL follow the V-Model ID dependency chain in reverse: UTS/UTP → MOD → {ITS, ITP, ARCH} → {STS, STP, SYS, HAZ} → {SCN, ATP, REQ}. For each level, the script SHALL identify all IDs that the changed ID or any ID in the suspect set references. | P1 | Upward traversal must follow the reverse hierarchy to find all transitive parents. | Test |
| REQ-007 | The script SHALL build the ID dependency graph by scanning all V-Model markdown files in the specified directory for cross-references between IDs using regex patterns for all known prefixes: REQ, ATP, SCN, SYS, STP, STS, ARCH, ITP, ITS, MOD, UTP, UTS, HAZ. | P1 | The dependency graph is implicit in the markdown files — IDs reference each other through in-text mentions. | Test |
| REQ-008 | The script SHALL accept multiple changed IDs in a single invocation (e.g., `impact-analysis.sh --downward REQ-001 REQ-002 <dir>`). | P1 | Multiple IDs may change simultaneously (e.g., a design review updates several requirements). | Test |
| REQ-009 | The script SHALL produce an `impact-report.md` file containing: (a) the list of changed IDs with their artifact type, (b) the suspect artifact list organized by V-Model level, (c) blast radius statistics (count of affected IDs per level), and (d) a suggested re-validation order. | P1 | The impact report must be human-readable and actionable for the engineering team. | Test |
| REQ-010 | The script SHALL support an `--output` flag to specify the output file path. When not specified, the default output SHALL be `impact-report.md` in the V-Model directory. | P2 | Allows CI pipelines and custom workflows to write the report to a specific location. | Test |
| REQ-011 | The script SHALL support a `--json` flag that outputs the impact report in machine-readable JSON format to stdout instead of writing a markdown file. | P1 | Machine-readable output enables CI integration and programmatic consumption. | Test |
| REQ-012 | The `--json` output SHALL conform to the schema: `{"changed_ids": [...], "direction": "downward|upward|full", "suspect_artifacts": {"REQ": [...], "SYS": [...], ...}, "blast_radius": {"total": N, "by_level": {"REQ": N, ...}}, "revalidation_order": [...]}`. | P1 | A defined JSON schema ensures downstream tools can reliably parse the output. | Test |
| REQ-013 | When a changed ID does not exist in any V-Model artifact, the script SHALL emit a warning to stderr identifying the unfound ID and continue processing any remaining IDs. | P1 | Graceful degradation: a typo in one ID should not prevent analysis of other valid IDs. | Test |
| REQ-014 | When no V-Model artifacts exist in the specified directory, the script SHALL fail with a clear error message ("No V-Model artifacts found in <dir>") and exit with code 1. | P1 | Empty directories must produce actionable error messages, not empty reports. | Test |
| REQ-015 | The script SHALL handle missing optional artifacts gracefully: if `architecture-design.md` does not exist, downward traversal SHALL stop at the system level and not report an error. | P1 | Not all V-Model layers may exist yet — the script must work with partial artifact sets. | Test |
| REQ-016 | The suggested re-validation order in the impact report SHALL list artifacts bottom-up for downward traversal (re-validate lowest-level tests first) and top-down for upward traversal (re-validate highest-level requirements first). | P2 | Re-validation order reflects the natural V-Model verification sequence. | Inspection |
| REQ-017 | The script SHALL NOT modify any existing V-Model artifacts — it is a read-only analysis tool. | P1 | Impact analysis must never alter the artifacts it analyzes; it is purely observational. | Inspection |
| REQ-018 | The script SHALL complete analysis within 10 seconds for a V-Model directory containing up to 20 artifact files with up to 500 total IDs. | P2 | Performance must be acceptable for interactive use and CI pipelines. | Test |
| REQ-019 | The script SHALL use regex-based parsing consistent with existing V-Model scripts (e.g., `validate-requirement-coverage.sh`, `build-matrix.sh`), requiring no runtime database or external tooling beyond standard Bash utilities. | P1 | Consistency with existing scripts ensures maintainability and portability. | Inspection |
| REQ-020 | The extension SHALL provide an `impact-analysis.ps1` PowerShell script that produces identical output structure, JSON schema, and exit codes as the Bash `impact-analysis.sh` script. | P3 | PowerShell parity ensures cross-platform support following the established convention. | Test |
| REQ-021 | The `extension.yml` SHALL register the new `speckit.v-model.impact-analysis` command with its file path and description. | P1 | All commands must be registered in the extension manifest for spec-kit discovery. | Inspection |
| REQ-022 | The `extension.yml` SHALL update the command description to indicate that impact-analysis is a deterministic script command (not AI-generated). | P1 | Users must understand that this command produces deterministic output, not AI-generated content. | Inspection |
| REQ-023 | When `--full` mode is used, the impact report SHALL clearly separate the upward and downward sections, showing which artifacts are upstream dependents and which are downstream dependents of the changed ID(s). | P1 | Users must be able to distinguish between upstream and downstream impact in a full traversal. | Test |
| REQ-024 | The script SHALL detect and handle circular references in the ID graph without entering an infinite loop. If a circular reference is detected, the script SHALL emit a warning and continue traversal. | P1 | Malformed artifacts could create circular references; the script must be robust against this. | Test |
| REQ-025 | The script SHALL accept the V-Model directory path as its last positional argument, consistent with existing script conventions (`validate-requirement-coverage.sh`, `build-matrix.sh`). | P1 | Consistent CLI conventions reduce user confusion and enable script composition. | Test |

### Non-Functional Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-NF-001 | The `impact-analysis.sh` script SHALL use regex-based parsing consistent with existing coverage validators, requiring no runtime database or external tooling beyond standard Bash utilities (awk, grep, sed). | P1 | Deterministic analysis must be self-contained and portable. | Inspection |
| REQ-NF-002 | The impact analysis output SHALL be deterministically reproducible: running the script with the same inputs SHALL always produce the same output. | P1 | Deterministic scripts must produce identical results on every run with identical inputs. | Test |
| REQ-NF-003 | The script SHALL handle V-Model directories of any depth (nested subdirectories) when scanning for artifact files. | P2 | Some projects may organize V-Model artifacts in subdirectories. | Test |

### Interface Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-IF-001 | The `impact-analysis.sh` script SHALL accept the following CLI syntax: `impact-analysis.sh [--downward|--upward|--full] [--json] [--output FILE] ID [ID...] <vmodel-dir>`. | P1 | Consistent CLI interface with clear flag semantics. | Test |
| REQ-IF-002 | The `impact-analysis.ps1` script SHALL accept equivalent PowerShell parameters: `Impact-Analysis.ps1 [-Downward|-Upward|-Full] [-Json] [-Output FILE] -Ids ID[,ID...] -VModelDir <dir>`. | P3 | PowerShell parity with idiomatic parameter naming. | Test |

### Constraint Requirements

| ID | Description | Priority | Rationale | Verification Method |
|----|-------------|----------|-----------|---------------------|
| REQ-CN-001 | The impact-analysis command SHALL NOT introduce any new ID prefixes — it works exclusively with existing ID prefixes (REQ, ATP, SCN, SYS, STP, STS, ARCH, ITP, ITS, MOD, UTP, UTS, HAZ). | P1 | Impact analysis is a cross-cutting read-only tool that analyzes existing artifacts. | Inspection |
| REQ-CN-002 | The `impact-analysis.sh` and `impact-analysis.ps1` scripts SHALL produce identical JSON output structure and exit codes when given the same inputs. | P3 | Cross-platform parity is a constitutional requirement. | Test |
| REQ-CN-003 | The script SHALL NOT require any V-Model artifacts beyond those already generated by existing commands — no new prerequisite files or configuration. | P1 | Impact analysis must work with any existing V-Model project without additional setup. | Inspection |

## Assumptions

- V-Model artifacts use the established ID patterns (e.g., `REQ-[0-9]{3}`, `SYS-[0-9]{3}`) consistently across all markdown files.
- ID cross-references appear as literal text in markdown files (e.g., "implements REQ-001" or "validates SYS-003").
- The V-Model directory structure follows the established convention (all artifacts in a single directory or with known subdirectory layout).
- HAZ-NNN IDs are included in the dependency graph alongside design and test IDs.
- The script is invoked manually or from CI — it is not called automatically by other V-Model commands.

## Dependencies

- **Existing V-Model artifacts**: At least one markdown file with valid ID references must exist in the V-Model directory.
- **`extension.yml`**: Must be updated to register the new command.
- **Existing scripts**: Follows regex patterns and CLI conventions established by `validate-requirement-coverage.sh`, `build-matrix.sh`, and `validate-hazard-coverage.sh`.

## Glossary

| Term | Definition |
|------|-----------|
| Blast Radius | The complete set of artifacts affected by a change to one or more IDs |
| Downward Traversal | Following the V-Model hierarchy from a changed ID to all downstream dependents (design → test) |
| Upward Traversal | Following the V-Model hierarchy from a changed ID to all upstream parents (test → design → requirements) |
| Full Traversal | Combining both downward and upward traversal to show the complete blast radius |
| Suspect Artifact | An artifact that is directly or transitively affected by a changed ID and requires re-validation |
| ID Dependency Graph | The implicit graph of cross-references between V-Model IDs across all markdown files |
| Re-validation Order | The suggested sequence for re-verifying suspect artifacts after a change |

---

**Total Requirements**: 33
**By Priority**: P1: 26 | P2: 4 | P3: 3
**By Verification Method**: Test: 25 | Inspection: 8 | Analysis: 0 | Demonstration: 0
