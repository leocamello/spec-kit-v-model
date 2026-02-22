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
- **`/speckit.v-model.trace`** — Build a regulatory-grade Quadruple Traceability Matrix (Matrix A + B + C + D)

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
specify extension add v-model --from https://github.com/leocamello/spec-kit-v-model/archive/refs/tags/v0.4.0.zip
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
Step 6: /speckit.v-model.trace                 →  Matrix A + B (+ system verification)
Step 7: /speckit.v-model.architecture-design   →  ARCH-NNN modules (IEEE 42010/4+1)
Step 8: /speckit.v-model.integration-test      →  ITP/ITS procedures (ISO 29119-4)
Step 9: /speckit.v-model.trace                 →  Matrix A + B + C (architecture traceability)
Step 10: /speckit.v-model.module-design        →  MOD-NNN modules (pseudocode + state machines)
Step 11: /speckit.v-model.unit-test            →  UTP/UTS procedures (white-box techniques)
Step 12: /speckit.v-model.trace                →  Matrix A + B + C + D (full traceability)
```

> **Progressive traceability:** The `/speckit.v-model.trace` command is run four times — after each design↔test pair — so coverage gaps are caught at each V-level rather than discovered at the end.

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

# 6. Build traceability matrix (Matrix A + B: + system verification)
/speckit.v-model.trace

# 7. Generate architecture design (IEEE 42010/Kruchten 4+1 views)
/speckit.v-model.architecture-design

# 8. Generate integration tests (ISO 29119-4 integration techniques)
/speckit.v-model.integration-test

# 9. Build traceability matrix (Matrix A + B + C: architecture traceability)
/speckit.v-model.trace

# 10. Generate module design (pseudocode, state machines, data structures)
/speckit.v-model.module-design

# 11. Generate unit test plan (white-box techniques, strict isolation)
/speckit.v-model.unit-test

# 12. Build traceability matrix (Matrix A + B + C + D: full traceability)
/speckit.v-model.trace

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
├── architecture-design.md       →  ARCH-NNN modules
├── integration-test.md          →  ITP/ITS procedures
├── module-design.md             →  MOD-NNN detailed modules
├── unit-test.md                 →  UTP/UTS unit test procedures
└── traceability-matrix.md       →  Matrix A + B + C + D
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
| Build traceability matrix | `build-matrix.sh` | Deterministic — audit-grade accuracy, 4 matrices |
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

#### 9. Build Traceability Matrix (Step 3/6/9/12)

```bash
/speckit.v-model.trace
```

Uses deterministic scripts (not AI) to build a regulatory-grade quadruple matrix. Run progressively — after acceptance for Matrix A, after system-test for A+B, after integration-test for A+B+C, after unit-test for A+B+C+D.

## ID Schema

The ID scheme encodes traceability directly in the identifier:

| Layer | Design ID | Test Case ID | Test Step ID | Matrix |
|-------|-----------|-------------|-------------|--------|
| Requirements ↔ Acceptance | `REQ-NNN` | `ATP-NNN-X` | `SCN-NNN-X#` | A |
| System ↔ System Test | `SYS-NNN` | `STP-NNN-X` | `STS-NNN-X#` | B |
| Architecture ↔ Integration | `ARCH-NNN` | `ITP-NNN-X` | `ITS-NNN-X#` | C |
| Module ↔ Unit Test | `MOD-NNN` | `UTP-NNN-X` | `UTS-NNN-X#` | D |

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
| BATS | 91 | Bash script logic (setup, coverage, system coverage, architecture coverage, module coverage, matrix, diff) |
| Pester | 91 | PowerShell script parity |
| Structural evals | 51 | ID format, template conformance, section completeness across all V-levels |
| LLM-as-judge evals | 36 | Requirements quality, BDD quality, design quality, traceability (requires API key) |

See [CONTRIBUTING.md](CONTRIBUTING.md#testing) for full details.

## Target Audience

- **Any engineering team** wanting rigorous spec + test pairing
- **Regulated industries** (medical devices, automotive, aerospace) needing audit-ready traceability artifacts

## License

[MIT](LICENSE)
