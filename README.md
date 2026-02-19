# V-Model Extension Pack for Spec Kit

An extension for [GitHub Spec Kit](https://github.com/github/spec-kit) that enforces the V-Model methodology: **every development specification has a simultaneously generated, paired testing specification with full traceability**.

## Features

- **`/speckit.v-model.requirements`** — Generate traceable requirements (REQ-NNN) from user input or existing `spec.md`
- **`/speckit.v-model.acceptance`** — Generate a three-tier Acceptance Test Plan (Test Cases + BDD Scenarios) with deterministic 100% coverage validation
- **`/speckit.v-model.trace`** — Build a regulatory-grade 3D Traceability Matrix (REQ → ATP → SCN)

## Installation

### Prerequisites

- [Spec Kit](https://github.com/github/spec-kit) v0.1.0 or higher
- A spec-kit project (directory with `.specify/` folder)

### Install from local directory

```bash
git clone https://github.com/leocamello/spec-kit-v-model.git
specify extension add --dev /path/to/spec-kit-v-model
```

### Verify installation

```bash
specify extension list
```

## Usage

### Recommended Workflow

```
/speckit.specify          →  Generate initial feature specification (core Spec Kit)
/speckit.v-model.requirements  →  Atomize spec into traceable REQ-NNN requirements
/speckit.v-model.acceptance    →  Generate test cases (ATP) and BDD scenarios (SCN)
/speckit.v-model.trace         →  Build traceability matrix (audit artifact)
/speckit.plan             →  Continue with standard Spec Kit flow
```

### 1. Generate Requirements

```bash
/speckit.v-model.requirements Build a user authentication system with OAuth2 support
```

Outputs `specs/{feature}/v-model/requirements.md` with traceable `REQ-NNN` IDs.

### 2. Generate Acceptance Test Plan

```bash
/speckit.v-model.acceptance
```

Reads `requirements.md` and generates:
- **Test Cases** (`ATP-NNN-X`) — logical validation conditions
- **User Scenarios** (`SCN-NNN-X#`) — BDD Given/When/Then executable steps

Validates 100% coverage via deterministic script (not AI self-assessment).

### 3. Build Traceability Matrix

```bash
/speckit.v-model.trace
```

Outputs a regulatory-grade matrix linking every REQ → ATP → SCN with coverage metrics.

## ID Schema

The ID scheme encodes traceability directly in the identifier:

| Tier | Format | Example | Meaning |
|------|--------|---------|---------|
| Requirement | `REQ-{NNN}` | `REQ-001` | Functional requirement #1 |
| Requirement | `REQ-{CAT}-{NNN}` | `REQ-NF-001` | Non-Functional requirement #1 |
| Test Case | `ATP-{NNN}-{X}` | `ATP-001-A` | Test Case A for REQ-001 |
| Test Case | `ATP-{CAT}-{NNN}-{X}` | `ATP-NF-001-A` | Test Case A for REQ-NF-001 |
| Scenario | `SCN-{NNN}-{X}{#}` | `SCN-001-A1` | Scenario 1 of ATP-001-A |
| Scenario | `SCN-{CAT}-{NNN}-{X}{#}` | `SCN-NF-001-A1` | Scenario 1 of ATP-NF-001-A |

Category prefixes: `NF` (Non-Functional), `IF` (Interface), `CN` (Constraint). Functional requirements have no prefix.

Reading `SCN-001-A1` tells you: Scenario 1 → of Test Case A → validating Requirement 001.

## Configuration

Optional configuration via `v-model-config.yml`:

```yaml
output_dir: "v-model"
id_prefixes:
  requirements: "REQ"
  test_cases: "ATP"
  scenarios: "SCN"
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
| BATS | 27 | Bash script logic (setup, coverage, matrix, diff) |
| Pester | 27 | PowerShell script parity |
| Structural evals | 15 | ID format, template conformance, BDD completeness |
| LLM-as-judge evals | 6 | Requirements quality (IEEE 29148), BDD quality, traceability |

See [CONTRIBUTING.md](CONTRIBUTING.md#testing) for full details.

## Target Audience

- **Any engineering team** wanting rigorous spec + test pairing
- **Regulated industries** (medical devices, automotive, aerospace) needing audit-ready traceability artifacts

## License

[MIT](LICENSE)
