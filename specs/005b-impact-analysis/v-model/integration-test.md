# Integration Test Plan: Impact Analysis

**Feature Branch**: `005b-impact-analysis`
**Created**: 2026-04-14
**Status**: Approved
**Source**: `specs/005b-impact-analysis/v-model/architecture-design.md`

## Overview

This document defines the Integration Test Plan for the Impact Analysis feature. Every architecture module in `architecture-design.md` has one or more Integration Test Cases (ITP), and every Test Case has one or more executable Integration Scenarios (ITS) in technical BDD format (Given/When/Then). Integration tests verify the interactions between architecture modules, focusing on data flow, interface contracts, and failure propagation across module boundaries. ITP numbering matches the parent ARCH module numbering (ITP-001 → ARCH-001, etc.).

## ID Schema

- **Integration Test Case**: `ITP-{NNN}-{X}` — where NNN matches the parent ARCH, X is a letter suffix (A, B, C...)
- **Integration Test Scenario**: `ITS-{NNN}-{X}{#}` — nested under the parent ITP, with numeric suffix (1, 2, 3...)
- Example: `ITS-001-A1` → Scenario 1 of Test Case A verifying ARCH-001 integration

## ISO 29119-4 Integration Test Techniques

Each test case MUST identify its technique by name:
- **Consumer-Driven Contract Testing (CDCT)** — Verifies data exchange contracts between producer and consumer modules
- **Fault Injection** — Tests error propagation across module boundaries
- **Interface Contract Testing** — Verifies API/function call contracts between modules
- **Data Flow Testing** — Verifies correct data transformation through a chain of modules

## Integration Tests

### Module Verification: ARCH-001 (File Scanner)

#### Test Case: ITP-001-A (File scanner output consumed by graph constructor)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Target View**: Interface View — ARCH-001 → ARCH-002 interface
**Description**: Verify the file path list produced by the file scanner is correctly consumed by the graph constructor to build the dependency graph.

* **Integration Scenario: ITS-001-A1**
  * **Given** a V-Model directory with 5 markdown files at various depths and the file scanner produces a list of all 5 paths
  * **When** the graph constructor receives the file path list from the file scanner
  * **Then** the graph constructor opens and processes all 5 files, extracting IDs from each

#### Test Case: ITP-001-B (File scanner returns empty list for directory with no markdown)

**Technique**: Fault Injection
**Target View**: Interface View — ARCH-001 → ARCH-002 fault path
**Description**: Verify the graph constructor handles an empty file list without crashing.

* **Integration Scenario: ITS-001-B1**
  * **Given** a V-Model directory with no markdown files and the file scanner returns an empty list
  * **When** the graph constructor receives the empty file list
  * **Then** the graph constructor produces an empty graph (no nodes, no edges) without error

---

### Module Verification: ARCH-002 (Graph Constructor)

#### Test Case: ITP-002-A (Graph adjacency lists consumed by downward traversal)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Target View**: Interface View — ARCH-002 → ARCH-003 interface
**Description**: Verify the adjacency lists produced by the graph constructor are correctly traversed by the downward traversal engine.

* **Integration Scenario: ITS-002-A1**
  * **Given** the graph constructor builds adjacency lists from files containing `REQ-001` → `SYS-001` → `ARCH-001` cross-references
  * **When** the downward traversal engine receives the graph and traverses from `REQ-001`
  * **Then** the traversal follows `referenced_by` edges and returns `{SYS-001, ARCH-001}` as suspects

#### Test Case: ITP-002-B (Traversal handles graph with no edges from changed ID)

**Technique**: Fault Injection
**Target View**: Interface View — ARCH-002 → ARCH-003 empty graph path
**Description**: Verify downward traversal returns an empty suspect set when the changed ID has no downstream references.

* **Integration Scenario: ITS-002-B1**
  * **Given** the graph constructor builds a graph where `MOD-001` exists but is not referenced by any other ID
  * **When** the downward traversal engine traverses from `MOD-001`
  * **Then** the suspect set is empty and the blast radius total is 0

---

### Module Verification: ARCH-003 (Downward Traversal)

#### Test Case: ITP-003-A (Downward traversal feeds markdown emitter)

**Technique**: Data Flow Testing
**Target View**: Interface View — ARCH-003 → ARCH-006 interface
**Description**: Verify downward traversal results flow correctly through to the markdown report emitter.

* **Integration Scenario: ITS-003-A1**
  * **Given** a graph where `REQ-001` has downstream dependents `SYS-001` and `ARCH-001`
  * **When** downward traversal from `REQ-001` completes and results are passed to the markdown emitter
  * **Then** `impact-report.md` contains both `SYS-001` and `ARCH-001` in the suspect artifacts section with correct blast radius of 2

---

### Module Verification: ARCH-004 (Upward Traversal)

#### Test Case: ITP-004-A (Graph adjacency lists consumed by upward traversal)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Target View**: Interface View — ARCH-002 → ARCH-004 interface
**Description**: Verify the adjacency lists are correctly traversed in the upward direction.

* **Integration Scenario: ITS-004-A1**
  * **Given** the graph constructor builds adjacency lists from files where `MOD-001` references `ARCH-001` which references `SYS-001`
  * **When** the upward traversal engine receives the graph and traverses from `MOD-001`
  * **Then** the traversal follows `references` edges and returns `{ARCH-001, SYS-001}` as upstream suspects

---

### Module Verification: ARCH-005 (Full Traversal Combiner)

#### Test Case: ITP-005-A (Full combiner merges downward and upward results)

**Technique**: Data Flow Testing
**Target View**: Interface View — ARCH-005 → ARCH-003 + ARCH-004 integration
**Description**: Verify the full combiner correctly invokes both traversals, merges results, and maintains upstream/downstream separation.

* **Integration Scenario: ITS-005-A1**
  * **Given** a graph where `SYS-002` has upstream parent `REQ-001` and downstream dependent `ARCH-002`
  * **When** the full combiner invokes downward traversal (returns `{ARCH-002}`) and upward traversal (returns `{REQ-001}`) from `SYS-002`
  * **Then** the combined result separates `REQ-001` as upstream and `ARCH-002` as downstream

#### Test Case: ITP-005-B (Full combiner deduplicates overlapping results)

**Technique**: Data Flow Testing
**Target View**: Interface View — ARCH-005 deduplication logic
**Description**: Verify the combiner handles IDs that appear in both upstream and downstream paths.

* **Integration Scenario: ITS-005-B1**
  * **Given** a graph with a cycle where `SYS-001` → `ARCH-001` → `SYS-001` and `SYS-001` also references `REQ-001`
  * **When** the full combiner processes `SYS-001`
  * **Then** `ARCH-001` appears in the downstream set and `REQ-001` in the upstream set, with no duplicates

---

### Module Verification: ARCH-006 (Markdown Report Emitter)

#### Test Case: ITP-006-A (Traversal results formatted as markdown report)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Target View**: Interface View — ARCH-003/005 → ARCH-006 interface
**Description**: Verify the markdown emitter correctly consumes traversal results and produces a well-formed report.

* **Integration Scenario: ITS-006-A1**
  * **Given** downward traversal results with suspects `{SYS: [SYS-001], ARCH: [ARCH-001]}`, blast radius `{total: 2, SYS: 1, ARCH: 1}`, and re-validation order `[ARCH-001, SYS-001]`
  * **When** the markdown emitter formats the results
  * **Then** `impact-report.md` contains "SYS-001" under a "SYS" section, "ARCH-001" under an "ARCH" section, blast radius total of 2, and the re-validation order lists ARCH-001 before SYS-001

#### Test Case: ITP-006-B (Full traversal results formatted with upstream/downstream separation)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-005 → ARCH-006 full mode
**Description**: Verify the markdown emitter creates separate sections for upstream and downstream in full mode.

* **Integration Scenario: ITS-006-B1**
  * **Given** full traversal results with upstream `{REQ: [REQ-001]}` and downstream `{ARCH: [ARCH-002]}`
  * **When** the markdown emitter formats the results in full mode
  * **Then** the report has an "Upstream" section with `REQ-001` and a "Downstream" section with `ARCH-002`

---

### Module Verification: ARCH-007 (JSON Report Emitter)

#### Test Case: ITP-007-A (Traversal results formatted as valid JSON)

**Technique**: Consumer-Driven Contract Testing (CDCT)
**Target View**: Interface View — ARCH-003/005 → ARCH-007 interface
**Description**: Verify the JSON emitter correctly transforms traversal results into schema-compliant JSON.

* **Integration Scenario: ITS-007-A1**
  * **Given** downward traversal results with suspects `{SYS: [SYS-001]}`, blast radius `{total: 1, SYS: 1}`, changed IDs `[REQ-001]`, direction `downward`
  * **When** the JSON emitter formats the results
  * **Then** stdout contains valid JSON with `"changed_ids": ["REQ-001"]`, `"direction": "downward"`, `"suspect_artifacts": {"SYS": ["SYS-001"]}`, `"blast_radius": {"total": 1, "by_level": {"SYS": 1}}`

---

### Module Verification: ARCH-008 (CLI Argument Parser)

#### Test Case: ITP-008-A (CLI parser configures the full pipeline)

**Technique**: Data Flow Testing
**Target View**: Interface View — ARCH-008 → ARCH-001/003/006/007 pipeline
**Description**: Verify the CLI parser correctly wires together the file scanner, graph constructor, traversal engine, and report emitter for an end-to-end analysis.

* **Integration Scenario: ITS-008-A1**
  * **Given** command-line arguments `--downward --json REQ-001 /path/to/vmodel`
  * **When** the CLI parser processes arguments and invokes the pipeline
  * **Then** the file scanner scans `/path/to/vmodel`, the graph constructor builds the graph, the downward traversal runs from `REQ-001`, and the JSON emitter outputs the result to stdout

#### Test Case: ITP-008-B (CLI parser selects correct traversal mode)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-008 → ARCH-003/004/005 routing
**Description**: Verify the CLI parser correctly routes `--upward` and `--full` to the appropriate traversal functions.

* **Integration Scenario: ITS-008-B1**
  * **Given** command-line arguments `--upward MOD-001 /path/to/vmodel`
  * **When** the CLI parser processes arguments
  * **Then** the upward traversal function (ARCH-004) is invoked, not the downward traversal

* **Integration Scenario: ITS-008-B2**
  * **Given** command-line arguments `--full SYS-001 /path/to/vmodel`
  * **When** the CLI parser processes arguments
  * **Then** the full combiner function (ARCH-005) is invoked

---

### Module Verification: ARCH-009 (PowerShell Impact Analysis)

#### Test Case: ITP-009-A (PowerShell produces identical results to Bash pipeline)

**Technique**: Equivalence Partitioning
**Target View**: Interface View — ARCH-009 parity with ARCH-001 through ARCH-008
**Description**: Verify end-to-end parity between the PowerShell and Bash implementations.

* **Integration Scenario: ITS-009-A1**
  * **Given** a V-Model directory with `REQ-001` → `SYS-001` → `ARCH-001` processed by both scripts
  * **When** Bash produces JSON with `--json --downward REQ-001 <dir>` and PowerShell produces JSON with `-Json -Downward -Ids REQ-001 -VModelDir <dir>`
  * **Then** both JSON outputs are structurally identical: same `changed_ids`, `suspect_artifacts`, `blast_radius`, and `revalidation_order`

---

### Module Verification: ARCH-010 (Extension Manifest Entries)

#### Test Case: ITP-010-A (Manifest file path references valid script)

**Technique**: Interface Contract Testing
**Target View**: Interface View — ARCH-010 → ARCH-008/009 script references
**Description**: Verify the extension manifest references a valid, existing script file.

* **Integration Scenario: ITS-010-A1**
  * **Given** the `extension.yml` entry for `speckit.v-model.impact-analysis` with a `file` path
  * **When** resolving the file path relative to the extension root
  * **Then** the referenced file exists and is executable (for shell scripts) or readable (for command definitions)

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Architecture Modules | 10 |
| Total Integration Test Cases (ITP) | 15 |
| Total Integration Scenarios (ITS) | 16 |
| ARCH → ITP Coverage | 100% |
| ITP → ITS Coverage | 100% |

**Validation Status**: ✅ Full Coverage
**Generated**: 2026-04-14
**Validated by**: `validate-architecture-coverage.sh` (deterministic)
