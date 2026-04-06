<div align="center">
    <img src="./media/spec-kit-v-model-logo.png" alt="V-Model Extension Pack Logo" width="500" height="500"/>
    <h1>V-Model Extension Pack for Spec Kit</h1>
    <h3><em>Every specification paired with its test. Full traceability.</em></h3>
</div>

<p align="center">
    <a href="https://github.com/leocamello/spec-kit-v-model/actions/workflows/ci.yml"><img src="https://github.com/leocamello/spec-kit-v-model/actions/workflows/ci.yml/badge.svg" alt="CI"/></a>
    <a href="https://github.com/leocamello/spec-kit-v-model/actions/workflows/evals.yml"><img src="https://github.com/leocamello/spec-kit-v-model/actions/workflows/evals.yml/badge.svg" alt="Evaluations"/></a>
    <a href="https://github.com/leocamello/spec-kit-v-model/stargazers"><img src="https://img.shields.io/github/stars/leocamello/spec-kit-v-model?style=social" alt="GitHub stars"/></a>
    <a href="https://github.com/leocamello/spec-kit-v-model/blob/main/LICENSE"><img src="https://img.shields.io/github/license/leocamello/spec-kit-v-model" alt="License"/></a>
    <a href="https://github.com/leocamello/spec-kit-v-model/releases/latest"><img src="https://img.shields.io/github/v/release/leocamello/spec-kit-v-model" alt="Latest Release"/></a>
</p>

---

An extension for [GitHub Spec Kit](https://github.com/github/spec-kit) that enforces the V-Model methodology: **every development specification has a simultaneously generated, paired testing specification with full traceability**.

## Features

- **`/speckit.v-model.requirements`** — Generate traceable requirements (REQ-NNN) from user input or existing `spec.md`
- **`/speckit.v-model.acceptance`** — Generate a three-tier Acceptance Test Plan (Test Cases + BDD Scenarios) with deterministic 100% coverage validation
- **`/speckit.v-model.system-design`** — Decompose requirements into IEEE 1016-compliant system components (SYS-NNN)
- **`/speckit.v-model.system-test`** — Generate ISO 29119-compliant system test plans (STP/STS)
- **`/speckit.v-model.architecture-design`** — IEEE 42010/Kruchten 4+1 architecture decomposition (ARCH-NNN) with Logical, Process, Interface, and Data Flow views
- **`/speckit.v-model.integration-test`** — ISO 29119-4 integration testing (ITP/ITS) with Interface Contract, Data Flow, Fault Injection, and Concurrency techniques
- **`/speckit.v-model.module-design`** — Detailed module design (MOD-NNN) with pseudocode, state machines, data structures, and error handling views
- **`/speckit.v-model.unit-test`** — Unit test plans (UTP/UTS) with Statement & Branch Coverage, Boundary Value Analysis, State Transition Testing, and strict isolation
- **`/speckit.v-model.hazard-analysis`** — ISO 14971/26262 Failure Mode and Effects Analysis (FMEA) with `HAZ-NNN` hazard identifiers, operational state awareness, and mitigation traceability
- **`/speckit.v-model.impact-analysis`** — Deterministic change impact analysis: trace a changed ID downward, upward, or both to identify all suspect artifacts and blast radius across V-Model levels
- **`/speckit.v-model.peer-review`** — AI-powered stateless linter for any V-Model artifact: evaluates against standards-based criteria (INCOSE, IEEE 1016/42010, ISO 29119/14971) and produces `PRF-{ARTIFACT}-NNN` findings with CI exit codes (0=clean, 1=blocks, 2=warning)
- **`/speckit.v-model.test-results`** — Ingest JUnit XML test results and optional Cobertura XML code coverage into the traceability matrix, flipping `⬜ Untested` to `✅ Passed` / `❌ Failed` / `⏭️ Skipped` with Date, Commit SHA, and Coverage columns (100% deterministic, no AI)
- **`/speckit.v-model.audit-report`** — Build a point-in-time release audit report from V-Model artifacts: artifact inventory with git SHAs, traceability matrices, coverage analysis, hazard management summary, anomaly/waiver cross-referencing, and compliance gating (RELEASE READY / RELEASE CANDIDATE / NOT READY) — 100% deterministic, no AI
- **`/speckit.v-model.trace`** — Build a regulatory-grade Traceability Matrix (Matrix A + B + C + D, plus Matrix H when hazard analysis exists)

## Installation

### Prerequisites

- [Spec Kit](https://github.com/github/spec-kit) v0.1.0 or higher
- A spec-kit project (directory with `.specify/` folder)

### Method 1: Install from catalog (when available)

```bash
specify extension add v-model
```

### Method 2: Install from GitHub release

```bash
specify extension add v-model --from https://github.com/leocamello/spec-kit-v-model/archive/refs/tags/v0.5.0.zip
```

### Method 3: Install from local directory (development)

```bash
git clone https://github.com/leocamello/spec-kit-v-model.git
specify extension add --dev /path/to/spec-kit-v-model
```

### Verify installation

```bash
specify extension list
```

## Usage

### Proactive Workflow (Recommended)

The V-Model extension integrates with Spec Kit's core workflow (`/speckit.specify` → `/speckit.plan` → `/speckit.tasks` → `/speckit.implement`). Use these V-Model commands between the specify and plan steps:

```
Step 1: /speckit.v-model.requirements          →  Traceable REQ-NNN from spec.md
Step 2: /speckit.v-model.acceptance            →  Paired ATP + SCN with 100% coverage
Step 3: /speckit.v-model.trace                 →  Matrix A (requirements ↔ acceptance)
Step 4: /speckit.v-model.system-design         →  SYS-NNN components (IEEE 1016 views)
Step 5: /speckit.v-model.system-test           →  STP/STS procedures (ISO 29119-4)
Step 6: /speckit.v-model.hazard-analysis       →  HAZ-NNN hazards (ISO 14971/26262 FMEA)
Step 7: /speckit.v-model.trace                 →  Matrix A + B + H (+ hazard traceability)
Step 8: /speckit.v-model.architecture-design   →  ARCH-NNN modules (IEEE 42010/4+1)
Step 9: /speckit.v-model.integration-test      →  ITP/ITS procedures (ISO 29119-4)
Step 10: /speckit.v-model.trace                →  Matrix A + B + C + H (architecture traceability)
Step 11: /speckit.v-model.module-design        →  MOD-NNN modules (pseudocode + state machines)
Step 12: /speckit.v-model.unit-test            →  UTP/UTS procedures (white-box techniques)
Step 13: /speckit.v-model.trace                →  Matrix A + B + C + D + H (full traceability)

# On change — run impact analysis to identify suspect artifacts:
/speckit.v-model.impact-analysis --downward REQ-001   →  Downstream suspects + blast radius
/speckit.v-model.impact-analysis --upward MOD-004     →  Upstream requirements at risk

# At any time — run peer review to lint any artifact:
/speckit.v-model.peer-review requirements.md           →  PRF-REQ-NNN findings (INCOSE criteria)
/speckit.v-model.peer-review system-design.md          →  PRF-SYS-NNN findings (IEEE 1016 criteria)

# After CI — ingest test results into the traceability matrix:
/speckit.v-model.test-results --input results.xml                          →  Update ⬜ Untested to ✅/❌/⏭️
/speckit.v-model.test-results --input results.xml --coverage cobertura.xml →  + code coverage on Matrix D

# Before release — build the audit report:
/speckit.v-model.audit-report <vmodel-dir>                                 →  release-audit-report.md
/speckit.v-model.audit-report <vmodel-dir> --json                          →  JSON for CI gating
```

> **Progressive traceability:** The `/speckit.v-model.trace` command is run after each design↔test pair — so coverage gaps are caught at each V-level rather than discovered at the end. Matrix H (hazard traceability) is automatically included when `hazard-analysis.md` exists.
>
> **Change impact analysis:** When any artifact changes, run `/speckit.v-model.impact-analysis` to deterministically identify all suspect artifacts across the V-Model before re-generating or re-validating.
>
> **Peer review:** Run `/speckit.v-model.peer-review` on any artifact at any time — it operates like ESLint for V-Model documents, catching structural and quality issues before the human reviewer sees them. Findings are stateless (regenerated each run) and advisory-only (not in the traceability chain).
>
> **Test results ingestion:** After CI completes, run `/speckit.v-model.test-results` to ingest JUnit XML results (and optional Cobertura XML coverage) into the traceability matrix — flipping `⬜ Untested` to `✅ Passed` / `❌ Failed` / `⏭️ Skipped` with audit metadata (Date + Commit SHA). This bridges "we planned to test it" → "we proved it works."
>
> **Release audit report:** Before submission, run `/speckit.v-model.audit-report` to produce a point-in-time `release-audit-report.md` — the single document you hand to the auditor. It inventories every artifact (pinned to Git SHAs), embeds traceability matrices, computes coverage, summarizes hazard mitigations, cross-references anomalies with waivers, and gates the release: ✅ RELEASE READY, ⚠️ RELEASE CANDIDATE (all anomalies waived), or ❌ NOT READY (unwaived failures).

**Example — Feature 002: Custom ID Prefix Support**

```bash
# Before: define the feature with spec-kit core
/speckit.specify Allow users to configure custom ID prefixes (e.g., SRS instead of REQ)

# 1. Generate traceable requirements from the spec
/speckit.v-model.requirements

# 2. Generate acceptance tests — validates 100% coverage automatically
/speckit.v-model.acceptance

# 3. Build traceability matrix (Matrix A: requirements ↔ acceptance)
/speckit.v-model.trace

# 4. Generate system design elements (IEEE 1016 views)
/speckit.v-model.system-design

# 5. Generate system test procedures (ISO 29119-4 techniques)
/speckit.v-model.system-test

# 6. Generate hazard analysis (ISO 14971/26262 FMEA)
/speckit.v-model.hazard-analysis

# 7. Build traceability matrix (Matrix A + B + H: + system & hazard verification)
/speckit.v-model.trace

# 8. Generate architecture design (IEEE 42010/Kruchten 4+1 views)
/speckit.v-model.architecture-design

# 9. Generate integration tests (ISO 29119-4 integration techniques)
/speckit.v-model.integration-test

# 10. Build traceability matrix (Matrix A + B + C + H: architecture traceability)
/speckit.v-model.trace

# 11. Generate module design (pseudocode, state machines, data structures)
/speckit.v-model.module-design

# 12. Generate unit test plan (white-box techniques, strict isolation)
/speckit.v-model.unit-test

# 13. Build traceability matrix (Matrix A + B + C + D + H: full traceability)
/speckit.v-model.trace

# 14. After CI — ingest test execution results into the matrix
/speckit.v-model.test-results --input test-results.xml

# 15. Before release — build the audit report
/speckit.v-model.audit-report

# After: continue with spec-kit core
/speckit.plan
/speckit.tasks
/speckit.implement
```

Each step produces artifacts in `specs/{feature}/v-model/`:

```
specs/{feature}/v-model/
├── requirements.md              →  REQ-NNN requirements
├── acceptance-plan.md           →  ATP + SCN test cases
├── system-design.md             →  SYS-NNN components
├── system-test.md               →  STP/STS procedures
├── hazard-analysis.md           →  HAZ-NNN hazards (FMEA register)
├── architecture-design.md       →  ARCH-NNN modules
├── integration-test.md          →  ITP/ITS procedures
├── module-design.md             →  MOD-NNN detailed modules
├── unit-test.md                 →  UTP/UTS unit test procedures
├── peer-review-{artifact}.md    →  PRF-NNN findings (stateless, advisory-only)
├── traceability-matrix.md       →  Matrix A + B + C + D + H
└── release-audit-report.md      →  Point-in-time audit package
```

### Key Principle: Scripts Verify, AI Generates

The V-Model commands use AI (GitHub Copilot) for creative translation —
turning specs into requirements and test plans. But all compliance-critical
calculations are performed by **deterministic scripts**:

| Concern | Handled by | Why |
|---------|-----------|-----|
| Generate requirements & test plans | AI (Copilot) | Creative translation from natural language |
| Validate requirements ↔ acceptance coverage | `validate-requirement-coverage.sh` | Deterministic — regex-based, mathematically correct |
| Validate system design ↔ system test coverage | `validate-system-coverage.sh` | Deterministic — SYS→STP→STS cross-reference |
| Validate architecture ↔ integration coverage | `validate-architecture-coverage.sh` | Deterministic — ARCH→ITP→ITS cross-reference |
| Validate module ↔ unit test coverage | `validate-module-coverage.sh` | Deterministic — ARCH→MOD→UTP→UTS cross-reference |
| Validate hazard ↔ system coverage | `validate-hazard-coverage.sh` | Deterministic — SYS→HAZ forward, HAZ→REQ/SYS backward, state consistency |
| Check peer-review findings | `peer-review-check.sh` | Deterministic — parse AI-generated review, exit 0/1/2 by severity |
| Ingest test results into matrix | `ingest-test-results.sh` | Deterministic — parse JUnit XML + Cobertura XML, update matrix in-place |
| Parse test results XML | `parse_test_results.py` | Deterministic — stdlib-only Python parser, JSON output |
| Build release audit report | `build-audit-report.sh` | Deterministic — artifact inventory, coverage analysis, anomaly/waiver cross-reference, compliance gating |
| Build traceability matrix | `build-matrix.sh` | Deterministic — audit-grade accuracy, up to 5 matrices (A–D + H) |
| Detect requirement changes | `diff-requirements.sh` | Deterministic — git-based diff |

### Command Reference

#### 1. Generate Requirements (Step 1)

```bash
/speckit.v-model.requirements Build a user authentication system with OAuth2 support
```

Outputs `specs/{feature}/v-model/requirements.md` with traceable `REQ-NNN` IDs.

#### 2. Generate Acceptance Test Plan (Step 2)

```bash
/speckit.v-model.acceptance
```

Reads `requirements.md` and generates:
- **Test Cases** (`ATP-NNN-X`) — logical validation conditions
- **User Scenarios** (`SCN-NNN-X#`) — BDD Given/When/Then executable steps

Validates 100% coverage via deterministic script (not AI self-assessment).

#### 3. Generate System Design (Step 4)

```bash
/speckit.v-model.system-design
```

Reads `requirements.md` and generates `system-design.md` with `SYS-NNN` components across four IEEE 1016 views (Decomposition, Dependency, Interface, Data Design).

#### 4. Generate System Test Plan (Step 5)

```bash
/speckit.v-model.system-test
```

Reads `system-design.md` and generates `system-test.md` with `STP-NNN-X` test procedures and `STS-NNN-X#` test steps using ISO 29119-4 techniques.

#### 5. Generate Architecture Design (Step 7)

```bash
/speckit.v-model.architecture-design
```

Reads `system-design.md` and generates `architecture-design.md` with `ARCH-NNN` modules across four IEEE 42010/Kruchten 4+1 views (Logical, Process, Interface, Data Flow).

#### 6. Generate Integration Test Plan (Step 8)

```bash
/speckit.v-model.integration-test
```

Reads `architecture-design.md` and generates `integration-test.md` with `ITP-NNN-X` test procedures and `ITS-NNN-X#` test steps using four integration techniques (Interface Contract, Data Flow, Fault Injection, Concurrency).

#### 7. Generate Module Design (Step 10)

```bash
/speckit.v-model.module-design
```

Reads `architecture-design.md` and generates `module-design.md` with `MOD-NNN` modules. Each module includes pseudocode (Algorithmic / Logic View), state machine diagrams, internal data structures, and error handling specifications. Modules tagged `[EXTERNAL]` or `[CROSS-CUTTING]` are handled with appropriate bypass rules.

#### 8. Generate Unit Test Plan (Step 11)

```bash
/speckit.v-model.unit-test
```

Reads `module-design.md` and generates `unit-test.md` with `UTP-NNN-X` test procedures and `UTS-NNN-X#` scenarios. Uses white-box techniques (Statement & Branch Coverage, Boundary Value Analysis, State Transition Testing, Equivalence Partitioning) with strict isolation — every external dependency is mocked via Dependency & Mock Registries.

#### 9. Hazard Analysis (Cross-Cutting)

```bash
/speckit.v-model.hazard-analysis
```

Reads `requirements.md` + `system-design.md` (+ optional `architecture-design.md`) and generates `hazard-analysis.md` with `HAZ-NNN` hazard identifiers. Each entry includes Failure Mode, Operational State, Effect, Severity, Likelihood, Risk Level, Mitigation (linked to REQ/SYS IDs), and Residual Risk. Supports progressive deepening — re-running after architecture appends ARCH-level failure modes.

#### 10. Impact Analysis (Deterministic)

```bash
/speckit.v-model.impact-analysis --downward REQ-001 <vmodel-dir>
/speckit.v-model.impact-analysis --upward MOD-004 <vmodel-dir>
/speckit.v-model.impact-analysis --full SYS-001 <vmodel-dir>
```

Uses deterministic scripts (not AI) to build a dependency graph from all V-Model markdown artifacts and traverse it to identify suspect artifacts affected by a change. `--downward` traces from requirements to tests/modules; `--upward` traces from modules/tests to requirements; `--full` combines both directions. Outputs a blast radius summary, suspect artifact list by V-Model level, and a re-validation order. Supports `--json` for CI integration.

#### 11. Peer Review (Cross-Cutting)

```bash
/speckit.v-model.peer-review requirements.md
/speckit.v-model.peer-review system-design.md
/speckit.v-model.peer-review hazard-analysis.md
```

AI-powered stateless linter for any V-Model artifact. Evaluates the artifact against standards-based criteria specific to its type (INCOSE for requirements, IEEE 1016 for system design, ISO 29119 for test plans, ISO 14971 for hazard analysis) and produces `PRF-{ARTIFACT}-NNN` findings with severity classifications (Critical, Major, Minor, Observation).

The companion `peer-review-check.sh` / `Peer-Review-Check.ps1` scripts parse the generated review and return CI exit codes: **0** = clean (no findings or observations only), **1** = Critical or Major findings (blocks PR), **2** = Minor findings only (warning). Findings are advisory-only — PRF IDs do not participate in the traceability chain.

#### 12. Ingest Test Results (Deterministic)

```bash
/speckit.v-model.test-results --input test-results.xml
/speckit.v-model.test-results --input test-results.xml --coverage cobertura.xml --coverage-map coverage-map.yml
```

Uses deterministic scripts (no AI) to parse JUnit XML test results and update the traceability matrix in-place, flipping `⬜ Untested` to `✅ Passed` / `❌ Failed` / `⏭️ Skipped`. Each updated row includes Date and Commit SHA for audit trail. Optionally accepts Cobertura XML code coverage reports — when provided, Matrix D rows gain a Coverage column (`95.0% stmt / 88.0% branch`) with `⚠` warnings when below threshold. Supports `--json` for CI integration. Exit codes: 0 = all passed, 1 = failures detected, 2 = no V-Model ID matches.

#### 13. Build Release Audit Report (Deterministic)

```bash
/speckit.v-model.audit-report <vmodel-dir>
/speckit.v-model.audit-report <vmodel-dir> --system-name "CBGMS" --version "2.1.0" --git-tag v2.1.0
/speckit.v-model.audit-report <vmodel-dir> --json
```

Uses deterministic scripts (no AI) to build a point-in-time release audit report — the single document you hand to the auditor. Discovers all V-Model artifacts (pinned to Git SHAs and timestamps), embeds traceability matrices with coverage analysis, summarizes hazard mitigations, and cross-references anomalies with a `waivers.md` file. Compliance gating: **RELEASE READY** (0 anomalies, exit 0), **RELEASE CANDIDATE** (all anomalies waived, exit 0), or **NOT READY** (unwaived failures, exit 1). Orphaned waivers (referencing non-existent test IDs) are flagged but do not block. Supports `--json` for CI integration.

#### 14. Build Traceability Matrix (Step 3/6/9/12)

```bash
/speckit.v-model.trace
```

Uses deterministic scripts (not AI) to build a regulatory-grade traceability matrix. Run progressively — after acceptance for Matrix A, after system-test for A+B, after integration-test for A+B+C, after unit-test for A+B+C+D. When `hazard-analysis.md` exists, Matrix H (Hazard Traceability: HAZ → Mitigation → Verification) is automatically appended.

## ID Schema

The ID scheme encodes traceability directly in the identifier:

| Layer | Design ID | Test Case ID | Test Step ID | Matrix |
|-------|-----------|-------------|-------------|--------|
| Requirements ↔ Acceptance | `REQ-NNN` | `ATP-NNN-X` | `SCN-NNN-X#` | A |
| System ↔ System Test | `SYS-NNN` | `STP-NNN-X` | `STS-NNN-X#` | B |
| Architecture ↔ Integration | `ARCH-NNN` | `ITP-NNN-X` | `ITS-NNN-X#` | C |
| Module ↔ Unit Test | `MOD-NNN` | `UTP-NNN-X` | `UTS-NNN-X#` | D |
| Hazard ↔ Mitigation (cross-cutting) | `HAZ-NNN` | — | — | H |

Category prefixes: `NF` (Non-Functional), `IF` (Interface), `CN` (Constraint). Functional requirements have no prefix (e.g., `REQ-NF-001`, `ATP-NF-001-A`).

Each ID is self-documenting — reading `SCN-001-A1` tells you: Scenario 1 → of Test Case A → validating Requirement 001. The same lineage applies at every level: `ITS-003-A2` → `ITP-003-A` → `ARCH-003`, and `UTS-001-A1` → `UTP-001-A` → `MOD-001`.

For a comprehensive explanation of ID formats, lifecycle, cross-level linking mechanisms, and end-to-end traceability examples, see the [Artifact ID Schema Guide](docs/id-schema-guide.md).

## Configuration

Optional configuration via `v-model-config.yml`:

```yaml
output_dir: "v-model"
id_prefixes:
  requirements: "REQ"
  test_cases: "ATP"
  scenarios: "SCN"
  system_components: "SYS"
  system_test_procedures: "STP"
  system_test_steps: "STS"
  architecture_modules: "ARCH"
  integration_test_procedures: "ITP"
  integration_test_steps: "ITS"
  module_designs: "MOD"
  unit_test_procedures: "UTP"
  unit_test_scenarios: "UTS"
coverage_threshold: 100
batch_size: 5
```

## Testing

```bash
# BATS tests (Bash scripts)
tests/bats/lib/bats-core/bin/bats tests/bats/*.bats

# Structural eval tests (Python, deterministic)
pip install -e ".[dev]"
pytest tests/evals/ -m structural -v

# LLM-as-judge evals (requires GOOGLE_API_KEY)
GOOGLE_API_KEY=... pytest tests/evals/ -m eval -v
```

| Layer | Tests | What it validates |
|-------|-------|-------------------|
| BATS | **364** | Bash script logic (setup, coverage, system coverage, architecture coverage, module coverage, hazard coverage, impact analysis, peer-review check, test-results ingestion, audit-report, validate-level, matrix, diff, parity) |
| Pester | 347 | PowerShell script parity |
| Structural evals | 89 | ID format, template conformance, section completeness across all V-levels including hazard analysis and impact analysis |
| LLM-as-judge evals | 42 | Requirements quality, BDD quality, design quality, hazard analysis quality, traceability (requires API key) |

See [CONTRIBUTING.md](CONTRIBUTING.md#testing) for full details.

## Target Audience

- **Any engineering team** wanting rigorous spec + test pairing
- **Regulated industries** (medical devices, automotive, aerospace) needing audit-ready traceability artifacts

## License

[MIT](LICENSE)
