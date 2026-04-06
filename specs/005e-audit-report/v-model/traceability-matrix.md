# Traceability Matrix

**Generated**: 2026-04-05
**Source**: `v-model/`

## Matrix A — Validation (User View)

| Requirement ID | Requirement Description | Test Case ID (ATP) | Validation Condition | Scenario ID (SCN) | Status |
|----------------|------------------------|--------------------|----------------------|--------------------|--------|
| **REQ-001** | The command SHALL accept a V-Model directory path and discover all V-Model artifacts within it. | ATP-001-A | Full artifact set discovered | SCN-001-A1 | ⬜ Untested |
| | | ATP-001-A | Partial artifact set discovered | SCN-001-A2 | ⬜ Untested |
| **REQ-002** | For each discovered artifact, the command SHALL extract its Git SHA and last-modified date. | ATP-002-A | Git SHA is 7-character abbreviated hash | SCN-002-A1 | ⬜ Untested |
| | | ATP-002-A | Date is ISO 8601 format | SCN-002-A2 | ⬜ Untested |
| **REQ-003** | The command SHALL generate an Artifact Inventory table (Section 2). | ATP-003-A | Inventory table has all required columns | SCN-003-A1 | ⬜ Untested |
| **REQ-004** | The command SHALL extract all traceability matrices and embed them in Section 3. | ATP-004-A | All present matrices embedded | SCN-004-A1 | ⬜ Untested |
| | | ATP-004-A | Partial matrices handled | SCN-004-A2 | ⬜ Untested |
| **REQ-005** | The command SHALL compute coverage analysis metrics (Section 4) for each matrix. | ATP-005-A | 100% coverage on clean project | SCN-005-A1 | ⬜ Untested |
| | | ATP-005-A | Gaps detected in incomplete project | SCN-005-A2 | ⬜ Untested |
| **REQ-006** | When hazard-analysis.md exists, the command SHALL extract HAZ-NNN entries for Section 5. | ATP-006-A | All HAZ entries in summary | SCN-006-A1 | ⬜ Untested |
| | | ATP-006-A | No hazard section when absent | SCN-006-A2 | ⬜ Untested |
| **REQ-007** | The command SHALL identify all anomalies: failed, skipped, and Critical/Major peer-review findings. | ATP-007-A | Failed test detected | SCN-007-A1 | ⬜ Untested |
| | | ATP-007-A | Skipped test detected | SCN-007-A2 | ⬜ Untested |
| | | ATP-007-A | Passed tests not listed | SCN-007-A3 | ⬜ Untested |
| **REQ-008** | When waivers.md exists, the command SHALL parse WAV-NNN entries. | ATP-008-A | Single waiver parsed | SCN-008-A1 | ⬜ Untested |
| | | ATP-008-A | Multiple waivers parsed | SCN-008-A2 | ⬜ Untested |
| | | ATP-008-A | No waivers.md present | SCN-008-A3 | ⬜ Untested |
| **REQ-009** | Anomalies with matching waivers SHALL be "Waived"; without SHALL be "BLOCKING". | ATP-009-A | Waived anomaly listed | SCN-009-A1 | ⬜ Untested |
| | | ATP-009-A | Unwaived anomaly BLOCKING | SCN-009-A2 | ⬜ Untested |
| **REQ-010** | The command SHALL compute compliance status: RELEASE READY / CANDIDATE / NOT READY. | ATP-010-A | RELEASE READY status | SCN-010-A1 | ⬜ Untested |
| | | ATP-010-B | RELEASE CANDIDATE status | SCN-010-B1 | ⬜ Untested |
| | | ATP-010-C | NOT READY status | SCN-010-C1 | ⬜ Untested |
| **REQ-011** | The command SHALL generate an Executive Summary (Section 1) with all required fields. | ATP-011-A | Executive summary populated | SCN-011-A1 | ⬜ Untested |
| **REQ-012** | The command SHALL generate a Signature Block (Section 7). | ATP-012-A | Signature block present | SCN-012-A1 | ⬜ Untested |
| **REQ-013** | The command SHALL accept --system-name, --version, --git-tag, --regulatory-context. | ATP-013-A | System name in executive summary | SCN-013-A1 | ⬜ Untested |
| | | ATP-013-A | Default values when omitted | SCN-013-A2 | ⬜ Untested |
| **REQ-014** | The command SHALL accept --output argument for the output file path. | ATP-014-A | Custom output path used | SCN-014-A1 | ⬜ Untested |
| | | ATP-014-A | Default output path | SCN-014-A2 | ⬜ Untested |
| **REQ-015** | The command SHALL return exit code 0 for RELEASE READY or RELEASE CANDIDATE. | ATP-015-A | Exit 0 on clean project | SCN-015-A1 | ⬜ Untested |
| | | ATP-015-B | Exit 0 when all waived | SCN-015-B1 | ⬜ Untested |
| **REQ-016** | The command SHALL return exit code 1 for NOT READY. | ATP-016-A | Exit 1 on unwaived failure | SCN-016-A1 | ⬜ Untested |
| **REQ-017** | The command SHALL return exit code 2 when required artifacts are missing. | ATP-017-A | Exit 2 missing requirements.md | SCN-017-A1 | ⬜ Untested |
| | | ATP-017-A | Exit 2 missing traceability-matrix.md | SCN-017-A2 | ⬜ Untested |
| **REQ-018** | The command SHALL support --json flag for structured JSON output. | ATP-018-A | JSON contains compliance_status | SCN-018-A1 | ⬜ Untested |
| | | ATP-018-A | JSON contains artifact inventory | SCN-018-A2 | ⬜ Untested |
| | | ATP-018-A | JSON contains anomalies with waiver status | SCN-018-A3 | ⬜ Untested |
| **REQ-019** | Orphaned waivers SHALL be reported without affecting compliance status. | ATP-019-A | Orphaned waiver detected | SCN-019-A1 | ⬜ Untested |
| **REQ-020** | The command SHALL print a human-readable summary to stderr. | ATP-020-A | Summary contains compliance status | SCN-020-A1 | ⬜ Untested |
| **REQ-NF-001** | The command SHALL be 100% deterministic. | ATP-NF-001-A | Deterministic output | SCN-NF-001-A1 | ⬜ Untested |
| **REQ-IF-001** | Bash CLI syntax: build-audit-report.sh <vmodel-dir> [options]. | ATP-IF-001-A | --help exits 0 | SCN-IF-001-A1 | ⬜ Untested |
| | | ATP-IF-001-A | Missing vmodel-dir exits 2 | SCN-IF-001-A2 | ⬜ Untested |
| **REQ-IF-002** | PowerShell parameters: Build-Audit-Report.ps1 -VModelDir <path> [options]. | ATP-IF-002-A | -Help exits 0 | SCN-IF-002-A1 | ⬜ Untested |
| | | ATP-IF-002-A | Missing -VModelDir exits 2 | SCN-IF-002-A2 | ⬜ Untested |
| **REQ-CN-001** | The command SHALL NOT use any AI or LLM. | ATP-CN-001-A | No AI dependencies | SCN-CN-001-A1 | ⬜ Untested |
| **REQ-CN-003** | The waivers.md SHALL follow structured WAV-NNN format. | ATP-CN-003-A | Waiver fields extracted | SCN-CN-003-A1 | ⬜ Untested |

### Matrix A Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 25 |
| **Total Test Cases (ATP)** | 28 |
| **Total Scenarios (SCN)** | 45 |
| **REQ → ATP Coverage** | 25/25 (100%) |
| **ATP → SCN Coverage** | 28/28 (100%) |

## Matrix B — Verification (Architectural View)

| Requirement ID | System Component (SYS) | Component Name | Test Case ID (STP) | Technique | Scenario ID (STS) | Status |
|----------------|------------------------|----------------|--------------------|-----------|--------------------|--------|
| **REQ-001** | SYS-001 | Artifact Discovery Engine | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| | SYS-001 | Artifact Discovery Engine | STP-001-A | Interface Contract Testing | STS-001-A2 | ⬜ Untested |
| | SYS-001 | Artifact Discovery Engine | STP-001-A | Interface Contract Testing | STS-001-A3 | ⬜ Untested |
| **REQ-002** | SYS-001 | Artifact Discovery Engine | STP-001-B | Equivalence Partitioning | STS-001-B1 | ⬜ Untested |
| | SYS-001 | Artifact Discovery Engine | STP-001-B | Equivalence Partitioning | STS-001-B2 | ⬜ Untested |
| **REQ-003** | SYS-001 | Artifact Discovery Engine | STP-001-A | Interface Contract Testing | STS-001-A1 | ⬜ Untested |
| **REQ-004** | SYS-002 | Matrix Extractor | STP-002-A | Equivalence Partitioning | STS-002-A1 | ⬜ Untested |
| | SYS-002 | Matrix Extractor | STP-002-A | Equivalence Partitioning | STS-002-A2 | ⬜ Untested |
| **REQ-005** | SYS-002 | Matrix Extractor | STP-002-B | Boundary Value Analysis | STS-002-B1 | ⬜ Untested |
| | SYS-002 | Matrix Extractor | STP-002-B | Boundary Value Analysis | STS-002-B2 | ⬜ Untested |
| | SYS-002 | Matrix Extractor | STP-002-B | Boundary Value Analysis | STS-002-B3 | ⬜ Untested |
| **REQ-006** | SYS-003 | Hazard Summary Extractor | STP-003-A | Equivalence Partitioning | STS-003-A1 | ⬜ Untested |
| | SYS-003 | Hazard Summary Extractor | STP-003-A | Equivalence Partitioning | STS-003-A2 | ⬜ Untested |
| | SYS-003 | Hazard Summary Extractor | STP-003-A | Equivalence Partitioning | STS-003-A3 | ⬜ Untested |
| **REQ-007** | SYS-004 | Anomaly Detector | STP-004-A | Equivalence Partitioning | STS-004-A1 | ⬜ Untested |
| | SYS-004 | Anomaly Detector | STP-004-A | Equivalence Partitioning | STS-004-A2 | ⬜ Untested |
| | SYS-004 | Anomaly Detector | STP-004-A | Equivalence Partitioning | STS-004-A3 | ⬜ Untested |
| **REQ-008** | SYS-004 | Anomaly Detector | STP-004-B | Interface Contract Testing | STS-004-B1 | ⬜ Untested |
| **REQ-009** | SYS-004 | Anomaly Detector | STP-004-B | Interface Contract Testing | STS-004-B2 | ⬜ Untested |
| | SYS-004 | Anomaly Detector | STP-004-B | Interface Contract Testing | STS-004-B3 | ⬜ Untested |
| **REQ-010** | SYS-005 | Compliance Status Engine | STP-005-A | Decision Table Testing | STS-005-A1 | ⬜ Untested |
| | SYS-005 | Compliance Status Engine | STP-005-A | Decision Table Testing | STS-005-A2 | ⬜ Untested |
| | SYS-005 | Compliance Status Engine | STP-005-A | Decision Table Testing | STS-005-A3 | ⬜ Untested |
| **REQ-011** | SYS-006 | Report Assembler | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| | SYS-006 | Report Assembler | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| **REQ-012** | SYS-006 | Report Assembler | STP-006-A | Interface Contract Testing | STS-006-A1 | ⬜ Untested |
| **REQ-013** | SYS-006 | Report Assembler | STP-006-A | Interface Contract Testing | STS-006-A2 | ⬜ Untested |
| **REQ-014** | SYS-006 | Report Assembler | STP-006-A | Interface Contract Testing | STS-006-A3 | ⬜ Untested |
| **REQ-015** | SYS-005 | Compliance Status Engine | STP-005-A | Decision Table Testing | STS-005-A1 | ⬜ Untested |
| **REQ-016** | SYS-005 | Compliance Status Engine | STP-005-A | Decision Table Testing | STS-005-A3 | ⬜ Untested |
| **REQ-017** | SYS-005 | Compliance Status Engine | STP-005-A | Decision Table Testing | STS-005-A4 | ⬜ Untested |
| **REQ-018** | SYS-007 | JSON Serializer | STP-007-A | Interface Contract Testing | STS-007-A1 | ⬜ Untested |
| | SYS-007 | JSON Serializer | STP-007-A | Interface Contract Testing | STS-007-A2 | ⬜ Untested |
| | SYS-007 | JSON Serializer | STP-007-A | Interface Contract Testing | STS-007-A3 | ⬜ Untested |
| **REQ-019** | SYS-004 | Anomaly Detector | STP-004-B | Interface Contract Testing | STS-004-B3 | ⬜ Untested |
| **REQ-020** | SYS-006 | Report Assembler | STP-006-A | Interface Contract Testing | STS-006-A4 | ⬜ Untested |

### Matrix B Coverage

| Metric | Value |
|--------|-------|
| **Total Requirements** | 20 |
| **Total System Components (SYS)** | 7 |
| **Total Test Procedures (STP)** | 10 |
| **Total Test Steps (STS)** | 30 |
| **REQ → SYS Coverage** | 20/20 (100%) |
| **SYS → STP Coverage** | 7/7 (100%) |
| **STP → STS Coverage** | 10/10 (100%) |

## Matrix C — Integration (Module Interaction View)

| System Component (SYS) | Architecture Module (ARCH) | Module Name | Test Case ID (ITP) | Technique | Scenario ID (ITS) | Status |
|-------------------------|---------------------------|-------------|--------------------|-----------|--------------------|--------|
| **SYS-006** | ARCH-001 | CLI Argument Parser | ITP-001-A | Interface Contract Testing | ITS-001-A1 | ⬜ Untested |
| | ARCH-001 | CLI Argument Parser | ITP-001-A | Interface Contract Testing | ITS-001-A2 | ⬜ Untested |
| **SYS-001** | ARCH-002 | File Discovery Module | ITP-002-A | Interface Contract Testing | ITS-002-A1 | ⬜ Untested |
| | ARCH-002 | File Discovery Module | ITP-002-A | Interface Contract Testing | ITS-002-A2 | ⬜ Untested |
| **SYS-002** | ARCH-003 | Matrix Parser Module | ITP-003-A | Data Flow Testing | ITS-003-A1 | ⬜ Untested |
| | ARCH-003 | Matrix Parser Module | ITP-003-A | Data Flow Testing | ITS-003-A2 | ⬜ Untested |
| **SYS-003** | ARCH-004 | Hazard Parser Module | ITP-004-A | Data Flow Testing | ITS-004-A1 | ⬜ Untested |
| | ARCH-004 | Hazard Parser Module | ITP-004-A | Data Flow Testing | ITS-004-A2 | ⬜ Untested |
| **SYS-004** | ARCH-005 | Anomaly Scanner Module | ITP-005-A | Interface Contract Testing | ITS-005-A1 | ⬜ Untested |
| | ARCH-005 | Anomaly Scanner Module | ITP-005-A | Interface Contract Testing | ITS-005-A2 | ⬜ Untested |
| | ARCH-006 | Waiver Parser Module | ITP-006-A | Data Flow Testing | ITS-006-A1 | ⬜ Untested |
| **SYS-005** | ARCH-007 | Cross-Reference Engine | ITP-007-A | Interface Contract Testing | ITS-007-A1 | ⬜ Untested |
| | ARCH-007 | Cross-Reference Engine | ITP-007-A | Interface Contract Testing | ITS-007-A2 | ⬜ Untested |
| **SYS-006** | ARCH-008 | Report Renderer Module | ITP-008-A | Interface Contract Testing | ITS-008-A1 | ⬜ Untested |
| | ARCH-008 | Report Renderer Module | ITP-008-A | Interface Contract Testing | ITS-008-A2 | ⬜ Untested |
| **SYS-007** | ARCH-009 | JSON Output Module | ITP-009-A | Interface Contract Testing | ITS-009-A1 | ⬜ Untested |

### Matrix C Coverage

| Metric | Value |
|--------|-------|
| **Total System Components (SYS)** | 7 |
| **Total Architecture Modules (ARCH)** | 9 |
| **Total Test Procedures (ITP)** | 9 |
| **Total Test Steps (ITS)** | 16 |
| **SYS → ARCH Coverage** | 7/7 (100%) |
| **ARCH → ITP Coverage** | 9/9 (100%) |
| **ITP → ITS Coverage** | 10/10 (100%) |

## Matrix D — Unit Verification (Detail View)

| Architecture Module (ARCH) | Module Design (MOD) | Module Name | Test Case ID (UTP) | Technique | Scenario ID (UTS) | Status |
|---------------------------|--------------------|--------------|--------------------|-----------|--------------------|---------| 
| **ARCH-001** | MOD-001 | parse_cli_args | UTP-001-A | Equivalence Partitioning | UTS-001-A1 | ⬜ Untested |
| | MOD-001 | parse_cli_args | UTP-001-A | Equivalence Partitioning | UTS-001-A2 | ⬜ Untested |
| | MOD-001 | parse_cli_args | UTP-001-B | Boundary Value Analysis | UTS-001-B1 | ⬜ Untested |
| | MOD-001 | parse_cli_args | UTP-001-B | Boundary Value Analysis | UTS-001-B2 | ⬜ Untested |
| | MOD-001 | parse_cli_args | UTP-001-B | Boundary Value Analysis | UTS-001-B3 | ⬜ Untested |
| **ARCH-002** | MOD-002 | discover_artifacts | UTP-002-A | Equivalence Partitioning | UTS-002-A1 | ⬜ Untested |
| | MOD-002 | discover_artifacts | UTP-002-A | Equivalence Partitioning | UTS-002-A2 | ⬜ Untested |
| | MOD-002 | discover_artifacts | UTP-002-A | Equivalence Partitioning | UTS-002-A3 | ⬜ Untested |
| | MOD-002 | discover_artifacts | UTP-002-B | Interface Testing | UTS-002-B1 | ⬜ Untested |
| | MOD-002 | discover_artifacts | UTP-002-B | Interface Testing | UTS-002-B2 | ⬜ Untested |
| **ARCH-003** | MOD-003 | parse_matrix_file | UTP-003-A | Equivalence Partitioning | UTS-003-A1 | ⬜ Untested |
| | MOD-003 | parse_matrix_file | UTP-003-A | Equivalence Partitioning | UTS-003-A2 | ⬜ Untested |
| | MOD-003 | parse_matrix_file | UTP-003-A | Equivalence Partitioning | UTS-003-A3 | ⬜ Untested |
| | MOD-004 | compute_coverage_metrics | UTP-003-B | Boundary Value Analysis | UTS-003-B1 | ⬜ Untested |
| | MOD-004 | compute_coverage_metrics | UTP-003-B | Boundary Value Analysis | UTS-003-B2 | ⬜ Untested |
| | MOD-004 | compute_coverage_metrics | UTP-004-A | Equivalence Partitioning | UTS-004-A1 | ⬜ Untested |
| | MOD-004 | compute_coverage_metrics | UTP-004-A | Equivalence Partitioning | UTS-004-A2 | ⬜ Untested |
| | MOD-004 | compute_coverage_metrics | UTP-004-A | Equivalence Partitioning | UTS-004-A3 | ⬜ Untested |
| **ARCH-004** | MOD-005 | parse_hazards | UTP-005-A | Equivalence Partitioning | UTS-005-A1 | ⬜ Untested |
| | MOD-005 | parse_hazards | UTP-005-A | Equivalence Partitioning | UTS-005-A2 | ⬜ Untested |
| **ARCH-005** | MOD-006 | scan_anomalies | UTP-006-A | Equivalence Partitioning | UTS-006-A1 | ⬜ Untested |
| | MOD-006 | scan_anomalies | UTP-006-A | Equivalence Partitioning | UTS-006-A2 | ⬜ Untested |
| | MOD-006 | scan_anomalies | UTP-006-A | Equivalence Partitioning | UTS-006-A3 | ⬜ Untested |
| | MOD-006 | scan_anomalies | UTP-006-A | Equivalence Partitioning | UTS-006-A4 | ⬜ Untested |
| **ARCH-006** | MOD-007 | parse_waivers | UTP-007-A | Equivalence Partitioning | UTS-007-A1 | ⬜ Untested |
| | MOD-007 | parse_waivers | UTP-007-A | Equivalence Partitioning | UTS-007-A2 | ⬜ Untested |
| | MOD-007 | parse_waivers | UTP-007-A | Equivalence Partitioning | UTS-007-A3 | ⬜ Untested |
| **ARCH-007** | MOD-008 | cross_reference_anomalies | UTP-008-A | Decision Table | UTS-008-A1 | ⬜ Untested |
| | MOD-008 | cross_reference_anomalies | UTP-008-A | Decision Table | UTS-008-A2 | ⬜ Untested |
| | MOD-008 | cross_reference_anomalies | UTP-008-A | Decision Table | UTS-008-A3 | ⬜ Untested |
| | MOD-008 | cross_reference_anomalies | UTP-008-A | Decision Table | UTS-008-A4 | ⬜ Untested |
| **ARCH-008** | MOD-009 | render_report | UTP-009-A | Equivalence Partitioning | UTS-009-A1 | ⬜ Untested |
| | MOD-009 | render_report | UTP-009-A | Equivalence Partitioning | UTS-009-A2 | ⬜ Untested |
| | MOD-009 | render_report | UTP-009-A | Equivalence Partitioning | UTS-009-A3 | ⬜ Untested |
| **ARCH-009** | MOD-010 | render_json | UTP-010-A | Interface Testing | UTS-010-A1 | ⬜ Untested |
| | MOD-010 | render_json | UTP-010-A | Interface Testing | UTS-010-A2 | ⬜ Untested |

### Matrix D Coverage

| Metric | Value |
|--------|-------|
| **Total Architecture Modules (ARCH)** | 9 |
| **Total Module Designs (MOD)** | 10 |
| **Total Test Procedures (UTP)** | 13 |
| **Total Test Steps (UTS)** | 36 |
| **ARCH → MOD Coverage** | 9/9 (100%) |
| **MOD → UTP Coverage** | 10/10 (100%) |
| **UTP → UTS Coverage** | 13/13 (100%) |

## Overall Coverage Summary

| Matrix | Level | Forward Coverage | Backward Coverage | Gaps | Orphans |
|--------|-------|-----------------|-------------------|------|---------|
| A (Validation) | REQ → SCN | 25/25 (100%) | 45/45 (100%) | 0 | 0 |
| B (Verification) | REQ → STS | 20/20 (100%) | 30/30 (100%) | 0 | 0 |
| C (Integration) | SYS → ITS | 7/7 (100%) | 16/16 (100%) | 0 | 0 |
| D (Unit) | ARCH → UTS | 9/9 (100%) | 36/36 (100%) | 0 | 0 |
