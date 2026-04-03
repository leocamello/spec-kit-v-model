# Traceability Matrix

**Generated**: 2026-04-03
**Source**: `specs/005b-impact-analysis/v-model/`

## Matrix A — Validation (User View)

| Requirement ID | Requirement Description | Test Case ID (ATP) | Validation Condition | Scenario ID (SCN) | Status |
|----------------|------------------------|--------------------|----------------------|--------------------|--------|
| **REQ-001** | The extension SHALL provide an `impact-analysis.sh` Bash script that accepts one or more V-Model IDs and a V-Model directory path, and produces an impact report identifying all affected artifacts. | ATP-001-A | Script accepts IDs and directory and produces impact report | SCN-001-A1 | ⬜ Untested |
| **REQ-002** | The `impact-analysis.sh` script SHALL support a `--downward` flag (default when no direction flag is specified) that traces from the given ID(s) to all downstream artifacts that depend on them. | ATP-002-A | Default mode traces downward without flag | SCN-002-A1 | ⬜ Untested |
| | | ATP-002-B | Explicit --downward flag produces identical output to default | SCN-002-B1 | ⬜ Untested |
| **REQ-003** | The `impact-analysis.sh` script SHALL support an `--upward` flag that traces from the given ID(s) to all upstream artifacts that the given IDs depend on or are derived from. | ATP-003-A | Upward mode traces to all upstream parent artifacts | SCN-003-A1 | ⬜ Untested |
| **REQ-004** | The `impact-analysis.sh` script SHALL support a `--full` flag that combines both downward and upward traversal from the given ID(s), producing the complete blast radius in both directions. | ATP-004-A | Full mode combines both downward and upward traversal | SCN-004-A1 | ⬜ Untested |
| **REQ-005** | The downward traversal SHALL follow the V-Model ID dependency chain: REQ → {ATP, SCN, SYS, HAZ} → {STP, STS, ARCH} → {ITP, ITS, MOD} → {UTP, UTS}. For each level, the script SHALL identify all IDs that reference the changed ID or any ID already in the suspect set. | ATP-005-A | Transitive downward traversal through all V-Model levels | SCN-005-A1 | ⬜ Untested |
| **REQ-006** | The upward traversal SHALL follow the V-Model ID dependency chain in reverse: UTS/UTP → MOD → {ITS, ITP, ARCH} → {STS, STP, SYS, HAZ} → {SCN, ATP, REQ}. For each level, the script SHALL identify all IDs that the changed ID or any ID in the suspect set references. | ATP-006-A | Transitive upward traversal through all V-Model levels | SCN-006-A1 | ⬜ Untested |
| **REQ-007** | The script SHALL build the ID dependency graph by scanning all V-Model markdown files in the specified directory for cross-references between IDs using regex patterns for all known prefixes: REQ, ATP, SCN, SYS, STP, STS, ARCH, ITP, ITS, MOD, UTP, UTS, HAZ. | ATP-007-A | Graph captures cross-references from all known ID prefixes | SCN-007-A1 | ⬜ Untested |
| | | ATP-007-A | Graph captures cross-references from all known ID prefixes | SCN-007-A2 | ⬜ Untested |
| **REQ-008** | The script SHALL accept multiple changed IDs in a single invocation (e.g., `impact-analysis.sh --downward REQ-001 REQ-002 <dir>`). | ATP-008-A | Multiple IDs processed in single invocation | SCN-008-A1 | ⬜ Untested |
| | | ATP-008-B | Overlapping suspect sets are deduplicated | SCN-008-B1 | ⬜ Untested |
| **REQ-009** | The script SHALL produce an `impact-report.md` file containing: (a) the list of changed IDs with their artifact type, (b) the suspect artifact list organized by V-Model level, (c) blast radius statistics (count of affected IDs per level), and (d) a suggested re-validation order. | ATP-009-A | Report contains all four required sections | SCN-009-A1 | ⬜ Untested |
| **REQ-010** | The script SHALL support an `--output` flag to specify the output file path. When not specified, the default output SHALL be `impact-report.md` in the V-Model directory. | ATP-010-A | --output flag writes report to specified path | SCN-010-A1 | ⬜ Untested |
| **REQ-011** | The script SHALL support a `--json` flag that outputs the impact report in machine-readable JSON format to stdout instead of writing a markdown file. | ATP-011-A | --json produces valid JSON to stdout | SCN-011-A1 | ⬜ Untested |
| **REQ-012** | The `--json` output SHALL conform to the schema: `{"changed_ids": [...], "direction": "downward | ATP-012-A | JSON output contains all required schema fields | SCN-012-A1 | ⬜ Untested |
| **REQ-013** | When a changed ID does not exist in any V-Model artifact, the script SHALL emit a warning to stderr identifying the unfound ID and continue processing any remaining IDs. | ATP-013-A | Warning emitted for nonexistent ID, processing continues | SCN-013-A1 | ⬜ Untested |
| | | ATP-013-A | Warning emitted for nonexistent ID, processing continues | SCN-013-A2 | ⬜ Untested |
| **REQ-014** | When no V-Model artifacts exist in the specified directory, the script SHALL fail with a clear error message ("No V-Model artifacts found in <dir>") and exit with code 1. | ATP-014-A | Error when directory has no V-Model markdown files | SCN-014-A1 | ⬜ Untested |
| **REQ-015** | The script SHALL handle missing optional artifacts gracefully: if `architecture-design.md` does not exist, downward traversal SHALL stop at the system level and not report an error. | ATP-015-A | Traversal stops gracefully when optional files are missing | SCN-015-A1 | ⬜ Untested |
| **REQ-016** | The suggested re-validation order in the impact report SHALL list artifacts bottom-up for downward traversal (re-validate lowest-level tests first) and top-down for upward traversal (re-validate highest-level requirements first). | ATP-016-A | Bottom-up order for downward traversal | SCN-016-A1 | ⬜ Untested |
| | | ATP-016-B | Top-down order for upward traversal | SCN-016-B1 | ⬜ Untested |
| **REQ-017** | The script SHALL NOT modify any existing V-Model artifacts — it is a read-only analysis tool. | ATP-017-A | No existing artifacts modified during analysis | SCN-017-A1 | ⬜ Untested |
| **REQ-018** | The script SHALL complete analysis within 10 seconds for a V-Model directory containing up to 20 artifact files with up to 500 total IDs. | ATP-018-A | Analysis completes within 10 seconds for standard project | SCN-018-A1 | ⬜ Untested |
| **REQ-019** | The script SHALL use regex-based parsing consistent with existing V-Model scripts (e.g., `validate-requirement-coverage.sh`, `build-matrix.sh`), requiring no runtime database or external tooling beyond standard Bash utilities. | ATP-019-A | Script uses only standard POSIX/Bash utilities | SCN-019-A1 | ⬜ Untested |
| **REQ-020** | The extension SHALL provide an `impact-analysis.ps1` PowerShell script that produces identical output structure, JSON schema, and exit codes as the Bash `impact-analysis.sh` script. | ATP-020-A | PowerShell produces identical JSON output structure | SCN-020-A1 | ⬜ Untested |
| **REQ-021** | The `extension.yml` SHALL register the new `speckit.v-model.impact-analysis` command with its file path and description. | ATP-021-A | Command registered in extension.yml | SCN-021-A1 | ⬜ Untested |
| **REQ-022** | The `extension.yml` SHALL update the command description to indicate that impact-analysis is a deterministic script command (not AI-generated). | ATP-022-A | Description indicates deterministic script-based command | SCN-022-A1 | ⬜ Untested |
| **REQ-023** | When `--full` mode is used, the impact report SHALL clearly separate the upward and downward sections, showing which artifacts are upstream dependents and which are downstream dependents of the changed ID(s). | ATP-023-A | Full traversal clearly separates upstream and downstream sections | SCN-023-A1 | ⬜ Untested |
| | | ATP-023-A | Full traversal clearly separates upstream and downstream sections | SCN-023-A2 | ⬜ Untested |
| **REQ-024** | The script SHALL detect and handle circular references in the ID graph without entering an infinite loop. If a circular reference is detected, the script SHALL emit a warning and continue traversal. | ATP-024-A | Cycle detection prevents infinite loop | SCN-024-A1 | ⬜ Untested |
| **REQ-025** | The script SHALL accept the V-Model directory path as its last positional argument, consistent with existing script conventions (`validate-requirement-coverage.sh`, `build-matrix.sh`). | ATP-025-A | V-Model directory correctly parsed as last positional argument | SCN-025-A1 | ⬜ Untested |
| **REQ-CN-001** | The impact-analysis command SHALL NOT introduce any new ID prefixes — it works exclusively with existing ID prefixes (REQ, ATP, SCN, SYS, STP, STS, ARCH, ITP, ITS, MOD, UTP, UTS, HAZ). | ATP-CN-001-A | Impact report uses only existing ID prefixes | SCN-CN-001-A1 | ⬜ Untested |
| **REQ-CN-002** | The `impact-analysis.sh` and `impact-analysis.ps1` scripts SHALL produce identical JSON output structure and exit codes when given the same inputs. | ATP-CN-002-A | Bash and PowerShell produce identical JSON results | SCN-CN-002-A1 | ⬜ Untested |
| **REQ-CN-003** | The script SHALL NOT require any V-Model artifacts beyond those already generated by existing commands — no new prerequisite files or configuration. | ATP-CN-003-A | Works with existing V-Model projects without additional files | SCN-CN-003-A1 | ⬜ Untested |
| **REQ-IF-001** | The `impact-analysis.sh` script SHALL accept the following CLI syntax: `impact-analysis.sh [--downward | ATP-IF-001-A | All CLI flags and arguments accepted | SCN-IF-001-A1 | ⬜ Untested |
| **REQ-IF-002** | The `impact-analysis.ps1` script SHALL accept equivalent PowerShell parameters: `Impact-Analysis.ps1 [-Downward | ATP-IF-002-A | PowerShell parameter syntax accepted | SCN-IF-002-A1 | ⬜ Untested |
| **REQ-NF-001** | The `impact-analysis.sh` script SHALL use regex-based parsing consistent with existing coverage validators, requiring no runtime database or external tooling beyond standard Bash utilities (awk, grep, sed). | ATP-NF-001-A | Consistent regex patterns with existing scripts | SCN-NF-001-A1 | ⬜ Untested |
| **REQ-NF-002** | The impact analysis output SHALL be deterministically reproducible: running the script with the same inputs SHALL always produce the same output. | ATP-NF-002-A | Identical output on repeated runs | SCN-NF-002-A1 | ⬜ Untested |
| **REQ-NF-003** | The script SHALL handle V-Model directories of any depth (nested subdirectories) when scanning for artifact files. | ATP-NF-003-A | Markdown files in subdirectories are included in the graph | SCN-NF-003-A1 | ⬜ Untested |

### Matrix A Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 33 |
| **Total Test Cases (ATP)** | 36 |
| **Total Scenarios (SCN)** | 39 |
| **REQ → ATP Coverage** | 33/33 (100%) |
| **ATP → SCN Coverage** | 36/36 (100%) |

## Matrix B — Verification (Architectural View)

| Requirement ID | System Component (SYS) | Component Name | Test Case ID (STP) | Technique | Scenario ID (STS) | Status |
|----------------|------------------------|----------------|--------------------|-----------|--------------------|--------|
| **REQ-001** | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-A | Boundary Value Analysis | STS-004-A1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-C | Fault Injection | STS-004-C1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-D | Interface Contract Testing | STS-004-D1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-E | Boundary Value Analysis | STS-004-E1 | ⬜ Untested |
| **REQ-002** | SYS-002 | Graph Traversal Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-C | Interface Contract Testing | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-F | Fault Injection | STS-002-F1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G2 | ⬜ Untested |
| **REQ-003** | SYS-002 | Graph Traversal Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-C | Interface Contract Testing | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-F | Fault Injection | STS-002-F1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G2 | ⬜ Untested |
| **REQ-004** | SYS-002 | Graph Traversal Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-C | Interface Contract Testing | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-F | Fault Injection | STS-002-F1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G2 | ⬜ Untested |
| **REQ-005** | SYS-002 | Graph Traversal Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-C | Interface Contract Testing | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-F | Fault Injection | STS-002-F1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G2 | ⬜ Untested |
| **REQ-006** | SYS-002 | Graph Traversal Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-C | Interface Contract Testing | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-F | Fault Injection | STS-002-F1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G2 | ⬜ Untested |
| **REQ-007** | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| **REQ-008** | SYS-002 | Graph Traversal Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-C | Interface Contract Testing | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-F | Fault Injection | STS-002-F1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G2 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-A | Boundary Value Analysis | STS-004-A1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-C | Fault Injection | STS-004-C1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-D | Interface Contract Testing | STS-004-D1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-E | Boundary Value Analysis | STS-004-E1 | ⬜ Untested |
| **REQ-009** | SYS-003 | Impact Report Formatter | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-D | Equivalence Partitioning | STS-003-D1 | ⬜ Untested |
| **REQ-010** | SYS-003 | Impact Report Formatter | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-D | Equivalence Partitioning | STS-003-D1 | ⬜ Untested |
| **REQ-011** | SYS-003 | Impact Report Formatter | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-D | Equivalence Partitioning | STS-003-D1 | ⬜ Untested |
| **REQ-012** | SYS-003 | Impact Report Formatter | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-D | Equivalence Partitioning | STS-003-D1 | ⬜ Untested |
| **REQ-013** | SYS-002 | Graph Traversal Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-C | Interface Contract Testing | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-F | Fault Injection | STS-002-F1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G2 | ⬜ Untested |
| **REQ-014** | SYS-004 | CLI Argument Parser | STP-004-A | Boundary Value Analysis | STS-004-A1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-C | Fault Injection | STS-004-C1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-D | Interface Contract Testing | STS-004-D1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-E | Boundary Value Analysis | STS-004-E1 | ⬜ Untested |
| **REQ-015** | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| **REQ-016** | SYS-002 | Graph Traversal Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-C | Interface Contract Testing | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-F | Fault Injection | STS-002-F1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G2 | ⬜ Untested |
| **REQ-017** | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| **REQ-018** | SYS-004 | CLI Argument Parser | STP-004-A | Boundary Value Analysis | STS-004-A1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-C | Fault Injection | STS-004-C1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-D | Interface Contract Testing | STS-004-D1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-E | Boundary Value Analysis | STS-004-E1 | ⬜ Untested |
| **REQ-019** | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| **REQ-020** | SYS-005 | PowerShell Impact Analysis Script | STP-005-A | Equivalence Partitioning | STS-005-A1 | ⬜ Untested |
| | SYS-005 | PowerShell Impact Analysis Script | STP-005-B | Interface Contract Testing | STS-005-B1 | ⬜ Untested |
| **REQ-021** | SYS-006 | Extension Manifest Update | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| **REQ-022** | SYS-006 | Extension Manifest Update | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| **REQ-023** | SYS-002 | Graph Traversal Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-C | Interface Contract Testing | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-F | Fault Injection | STS-002-F1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G2 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-D | Equivalence Partitioning | STS-003-D1 | ⬜ Untested |
| **REQ-024** | SYS-002 | Graph Traversal Engine | STP-002-A | Interface Contract Testing | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-B | Interface Contract Testing | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-C | Interface Contract Testing | STS-002-C1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-D | Fault Injection | STS-002-D1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-E | Equivalence Partitioning | STS-002-E2 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-F | Fault Injection | STS-002-F1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G1 | ⬜ Untested |
| | SYS-002 | Graph Traversal Engine | STP-002-G | Interface Contract Testing | STS-002-G2 | ⬜ Untested |
| **REQ-025** | SYS-004 | CLI Argument Parser | STP-004-A | Boundary Value Analysis | STS-004-A1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-C | Fault Injection | STS-004-C1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-D | Interface Contract Testing | STS-004-D1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-E | Boundary Value Analysis | STS-004-E1 | ⬜ Untested |
| **REQ-CN-001** | SYS-004 | CLI Argument Parser | STP-004-A | Boundary Value Analysis | STS-004-A1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-C | Fault Injection | STS-004-C1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-D | Interface Contract Testing | STS-004-D1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-E | Boundary Value Analysis | STS-004-E1 | ⬜ Untested |
| | SYS-006 | Extension Manifest Update | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| **REQ-CN-002** | SYS-005 | PowerShell Impact Analysis Script | STP-005-A | Equivalence Partitioning | STS-005-A1 | ⬜ Untested |
| | SYS-005 | PowerShell Impact Analysis Script | STP-005-B | Interface Contract Testing | STS-005-B1 | ⬜ Untested |
| **REQ-CN-003** | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-006 | Extension Manifest Update | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| **REQ-IF-001** | SYS-004 | CLI Argument Parser | STP-004-A | Boundary Value Analysis | STS-004-A1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-B | Equivalence Partitioning | STS-004-B1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-C | Fault Injection | STS-004-C1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-D | Interface Contract Testing | STS-004-D1 | ⬜ Untested |
| | SYS-004 | CLI Argument Parser | STP-004-E | Boundary Value Analysis | STS-004-E1 | ⬜ Untested |
| **REQ-IF-002** | SYS-005 | PowerShell Impact Analysis Script | STP-005-A | Equivalence Partitioning | STS-005-A1 | ⬜ Untested |
| | SYS-005 | PowerShell Impact Analysis Script | STP-005-B | Interface Contract Testing | STS-005-B1 | ⬜ Untested |
| **REQ-NF-001** | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| **REQ-NF-002** | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-A | Interface Contract Testing | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-B | Interface Contract Testing | STS-003-B1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-C | Boundary Value Analysis | STS-003-C1 | ⬜ Untested |
| | SYS-003 | Impact Report Formatter | STP-003-D | Equivalence Partitioning | STS-003-D1 | ⬜ Untested |
| **REQ-NF-003** | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-C | Fault Injection | STS-001-C1 | ⬜ Untested |
| | SYS-001 | ID Dependency Graph Builder | STP-001-D | Boundary Value Analysis | STS-001-D1 | ⬜ Untested |

### Matrix B Coverage

| Metric | Value |
|--------|-------|
| **Total System Components (SYS)** | 6 |
| **Total System Test Cases (STP)** | 23 |
| **Total System Scenarios (STS)** | 26 |
| **REQ → SYS Coverage** | 33/33 (100%) |
| **SYS → STP Coverage** | 6/6 (100%) |

## Matrix C — Integration Verification (Module Boundary View)

| System Component (SYS) | Parent REQs | Architecture Module (ARCH) | Module Name | Test Case ID (ITP) | Technique | Scenario ID (ITS) | Status |
|------------------------|-------------|---------------------------|-------------|--------------------|-----------|--------------------|--------|
| SYS-001 (REQ-001, REQ-007, REQ-015, REQ-017, REQ-019, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-CN-003) | REQ-001, REQ-007, REQ-015, REQ-017, REQ-019, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-CN-003 | ARCH-001 | File Scanner | ITP-001-A | Consumer-Driven Contract Testing (CDCT) | ITS-001-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-007, REQ-015, REQ-017, REQ-019, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-CN-003) | REQ-001, REQ-007, REQ-015, REQ-017, REQ-019, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-CN-003 | ARCH-001 | File Scanner | ITP-001-B | Fault Injection | ITS-001-B1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-007, REQ-015, REQ-017, REQ-019, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-CN-003) | REQ-001, REQ-007, REQ-015, REQ-017, REQ-019, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-CN-003 | ARCH-002 | Graph Constructor | ITP-002-A | Consumer-Driven Contract Testing (CDCT) | ITS-002-A1 | ⬜ Untested |
| SYS-001 (REQ-001, REQ-007, REQ-015, REQ-017, REQ-019, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-CN-003) | REQ-001, REQ-007, REQ-015, REQ-017, REQ-019, REQ-NF-001, REQ-NF-002, REQ-NF-003, REQ-CN-003 | ARCH-002 | Graph Constructor | ITP-002-B | Fault Injection | ITS-002-B1 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-013, REQ-016, REQ-023, REQ-024) | REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-013, REQ-016, REQ-023, REQ-024 | ARCH-003 | Downward Traversal | ITP-003-A | Data Flow Testing | ITS-003-A1 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-013, REQ-016, REQ-023, REQ-024) | REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-013, REQ-016, REQ-023, REQ-024 | ARCH-004 | Upward Traversal | ITP-004-A | Consumer-Driven Contract Testing (CDCT) | ITS-004-A1 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-013, REQ-016, REQ-023, REQ-024) | REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-013, REQ-016, REQ-023, REQ-024 | ARCH-005 | Full Traversal Combiner | ITP-005-A | Data Flow Testing | ITS-005-A1 | ⬜ Untested |
| SYS-002 (REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-013, REQ-016, REQ-023, REQ-024) | REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-008, REQ-013, REQ-016, REQ-023, REQ-024 | ARCH-005 | Full Traversal Combiner | ITP-005-B | Data Flow Testing | ITS-005-B1 | ⬜ Untested |
| SYS-003 (REQ-009, REQ-010, REQ-011, REQ-012, REQ-023, REQ-NF-002) | REQ-009, REQ-010, REQ-011, REQ-012, REQ-023, REQ-NF-002 | ARCH-006 | Markdown Report Emitter | ITP-006-A | Consumer-Driven Contract Testing (CDCT) | ITS-006-A1 | ⬜ Untested |
| SYS-003 (REQ-009, REQ-010, REQ-011, REQ-012, REQ-023, REQ-NF-002) | REQ-009, REQ-010, REQ-011, REQ-012, REQ-023, REQ-NF-002 | ARCH-006 | Markdown Report Emitter | ITP-006-B | Interface Contract Testing | ITS-006-B1 | ⬜ Untested |
| SYS-003 (REQ-009, REQ-010, REQ-011, REQ-012, REQ-023, REQ-NF-002) | REQ-009, REQ-010, REQ-011, REQ-012, REQ-023, REQ-NF-002 | ARCH-007 | JSON Report Emitter | ITP-007-A | Consumer-Driven Contract Testing (CDCT) | ITS-007-A1 | ⬜ Untested |
| SYS-004 (REQ-001, REQ-008, REQ-014, REQ-018, REQ-025, REQ-IF-001, REQ-CN-001) | REQ-001, REQ-008, REQ-014, REQ-018, REQ-025, REQ-IF-001, REQ-CN-001 | ARCH-008 | CLI Argument Parser | ITP-008-A | Data Flow Testing | ITS-008-A1 | ⬜ Untested |
| SYS-004 (REQ-001, REQ-008, REQ-014, REQ-018, REQ-025, REQ-IF-001, REQ-CN-001) | REQ-001, REQ-008, REQ-014, REQ-018, REQ-025, REQ-IF-001, REQ-CN-001 | ARCH-008 | CLI Argument Parser | ITP-008-B | Interface Contract Testing | ITS-008-B1 | ⬜ Untested |
| SYS-004 (REQ-001, REQ-008, REQ-014, REQ-018, REQ-025, REQ-IF-001, REQ-CN-001) | REQ-001, REQ-008, REQ-014, REQ-018, REQ-025, REQ-IF-001, REQ-CN-001 | ARCH-008 | CLI Argument Parser | ITP-008-B | Interface Contract Testing | ITS-008-B2 | ⬜ Untested |
| SYS-005 (REQ-020, REQ-CN-002, REQ-IF-002) | REQ-020, REQ-CN-002, REQ-IF-002 | ARCH-009 | PowerShell Impact Analysis | ITP-009-A | Equivalence Partitioning | ITS-009-A1 | ⬜ Untested |
| SYS-006 (REQ-021, REQ-022, REQ-CN-001, REQ-CN-003) | REQ-021, REQ-022, REQ-CN-001, REQ-CN-003 | ARCH-010 | Extension Manifest Entries | ITP-010-A | Interface Contract Testing | ITS-010-A1 | ⬜ Untested |

### Matrix C Coverage

| Metric | Value |
|--------|-------|
| **Total Architecture Modules (ARCH)** | 10 |
| **Total Cross-Cutting Modules** | 0 |
| **Total Integration Test Cases (ITP)** | 15 |
| **Total Integration Scenarios (ITS)** | 16 |
| **SYS → ARCH Coverage** | 6/6 (100%) |
| **ARCH → ITP Coverage** | 10/10 (100%) |

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
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | scan_files | UTP-001-A | Input Domain Testing | UTS-001-A1 | ⬜ Untested |
| ARCH-001 (SYS-001) | SYS-001 | MOD-001 | scan_files | UTP-001-B | Boundary Value Analysis | UTS-001-B1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | build_graph | UTP-002-A | Input Domain Testing | UTS-002-A1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | build_graph | UTP-002-A | Input Domain Testing | UTS-002-A2 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-002 | build_graph | UTP-002-B | Statement Coverage | UTS-002-B1 | ⬜ Untested |
| ARCH-002 (SYS-001) | SYS-001 | MOD-003 | classify_id | UTP-003-A | Equivalence Partitioning | UTS-003-A1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-003 | classify_id | UTP-003-A | Equivalence Partitioning | UTS-003-A1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | traverse_downward | UTP-004-A | Input Domain Testing | UTS-004-A1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | traverse_downward | UTP-004-B | Input Domain Testing | UTS-004-B1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | traverse_downward | UTP-004-C | Error Guessing | UTS-004-C1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-004 | traverse_downward | UTP-004-D | Boundary Value Analysis | UTS-004-D1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-007 | build_revalidation_order | UTP-007-A | Input Domain Testing | UTS-007-A1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-007 | build_revalidation_order | UTP-007-B | Input Domain Testing | UTS-007-B1 | ⬜ Untested |
| ARCH-003 (SYS-002) | SYS-002 | MOD-012 | warn_unknown_id | UTP-012-A | Input Domain Testing | UTS-012-A1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-003 | classify_id | UTP-003-A | Equivalence Partitioning | UTS-003-A1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-005 | traverse_upward | UTP-005-A | Input Domain Testing | UTS-005-A1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-007 | build_revalidation_order | UTP-007-A | Input Domain Testing | UTS-007-A1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-007 | build_revalidation_order | UTP-007-B | Input Domain Testing | UTS-007-B1 | ⬜ Untested |
| ARCH-004 (SYS-002) | SYS-002 | MOD-012 | warn_unknown_id | UTP-012-A | Input Domain Testing | UTS-012-A1 | ⬜ Untested |
| ARCH-005 (SYS-002) | SYS-002 | MOD-006 | traverse_full | UTP-006-A | Input Domain Testing | UTS-006-A1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-008 | format_markdown | UTP-008-A | Statement Coverage | UTS-008-A1 | ⬜ Untested |
| ARCH-006 (SYS-003) | SYS-003 | MOD-008 | format_markdown | UTP-008-B | Branch Coverage | UTS-008-B1 | ⬜ Untested |
| ARCH-007 (SYS-003) | SYS-003 | MOD-009 | format_json | UTP-009-A | Input Domain Testing | UTS-009-A1 | ⬜ Untested |
| ARCH-007 (SYS-003) | SYS-003 | MOD-009 | format_json | UTP-009-B | Error Guessing | UTS-009-B1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-010 | parse_args | UTP-010-A | Input Domain Testing | UTS-010-A1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-010 | parse_args | UTP-010-B | Error Guessing | UTS-010-B1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-010 | parse_args | UTP-010-C | Boundary Value Analysis | UTS-010-C1 | ⬜ Untested |
| ARCH-008 (SYS-004) | SYS-004 | MOD-011 | main | UTP-011-A | Statement Coverage | UTS-011-A1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-013 | Invoke-ImpactAnalysis | UTP-013-A | Equivalence Partitioning | UTS-013-A1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-014 | Build-DependencyGraph | UTP-014-A | Equivalence Partitioning | UTS-014-A1 | ⬜ Untested |
| ARCH-009 (SYS-005) | SYS-005 | MOD-015 | Format-ImpactReport | UTP-015-A | Equivalence Partitioning | UTS-015-A1 | ⬜ Untested |
| ARCH-010 (SYS-006) | SYS-006 | MOD-016 | Manifest Configuration | UTP-016-A | Input Domain Testing | UTS-016-A1 | ⬜ Untested |

### Matrix D Coverage

| Metric | Value |
|--------|-------|
| **Total Module Designs (MOD)** | 16 |
| **External Modules** | 0 |
| **Testable Modules** | 16 |
| **Total Unit Test Cases (UTP)** | 26 |
| **Total Unit Scenarios (UTS)** | 27 |
| **ARCH → MOD Coverage** | 10/10 (100%) |
| **MOD → UTP Coverage** | 16/16 (100%) |

## Audit Notes

- **Matrix generated by**: `build-matrix.sh` (deterministic regex parser)
- **Source documents**: `requirements.md`, `acceptance-plan.md`, `system-design.md`, `system-test.md`, `architecture-design.md`, `integration-test.md`, `module-design.md`, `unit-test.md`
- **Last validated**: 2026-04-03
