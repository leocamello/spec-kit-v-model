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

### Method 1: Install from catalog (when available)

```bash
specify extension add v-model
```

### Method 2: Install from GitHub release

```bash
specify extension add v-model --from https://github.com/leocamello/spec-kit-v-model/archive/refs/tags/v0.1.0.zip
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

The V-Model extension integrates with Spec Kit's specification-driven
development flow. Use this workflow when starting a **new feature**:

```
Step 1: /speckit.specify          →  Feature specification (user stories, requirements)
Step 2: /speckit.v-model.requirements  →  Traceable REQ-NNN requirements from spec.md
Step 3: /speckit.v-model.acceptance    →  Paired test plan (ATP + SCN) with 100% coverage
Step 4: /speckit.plan             →  Implementation plan (tech context, research, design)
Step 5: /speckit.tasks            →  Dependency-ordered task list from plan + spec
Step 6: /speckit.implement        →  Build the feature (tasks guide implementation)
Step 7: /speckit.v-model.trace         →  Traceability matrix (audit artifact, post-implementation)
```

**Example — Feature 002: Custom ID Prefix Support**

```bash
# 1. Define the feature
/speckit.specify Allow users to configure custom ID prefixes (e.g., SRS instead of REQ)

# 2. Generate traceable requirements from the spec
/speckit.v-model.requirements

# 3. Generate acceptance tests — validates 100% coverage automatically
/speckit.v-model.acceptance

# 4. Plan the implementation
/speckit.plan

# 5. Break into tasks
/speckit.tasks

# 6. Implement (tasks guide you phase by phase)
/speckit.implement

# 7. After implementation, generate the audit-ready traceability matrix
/speckit.v-model.trace
```

Each step produces artifacts in `specs/{feature}/`:

```
specs/002-custom-id-prefix/
├── spec.md                          # Step 1: Feature specification
├── v-model/
│   ├── requirements.md              # Step 2: REQ-001, REQ-002, ...
│   ├── acceptance-plan.md           # Step 3: ATP-001-A → SCN-001-A1, ...
│   └── traceability-matrix.md       # Step 7: Bidirectional RTM
├── plan.md                          # Step 4: Technical plan + research
├── research.md                      # Step 4: Technology decisions
├── tasks.md                         # Step 5: Ordered task list
└── checklists/
    └── requirements.md              # Auto-generated quality checklist
```

### Key Principle: Scripts Verify, AI Generates

The V-Model commands use AI (GitHub Copilot) for creative translation —
turning specs into requirements and test plans. But all compliance-critical
calculations are performed by **deterministic scripts**:

| Concern | Handled by | Why |
|---------|-----------|-----|
| Generate requirements | AI (Copilot) | Creative translation from natural language |
| Generate test cases | AI (Copilot) | Creative translation from requirements |
| Validate coverage | `validate-coverage.sh` | Deterministic — regex-based, mathematically correct |
| Build traceability matrix | `build-matrix.sh` | Deterministic — regex-based, audit-grade accuracy |
| Detect requirement changes | `diff-requirements.sh` | Deterministic — git-based diff |

### Command Reference

#### 1. Generate Requirements (Step 2)

```bash
/speckit.v-model.requirements Build a user authentication system with OAuth2 support
```

Outputs `specs/{feature}/v-model/requirements.md` with traceable `REQ-NNN` IDs.

#### 2. Generate Acceptance Test Plan (Step 3)

```bash
/speckit.v-model.acceptance
```

Reads `requirements.md` and generates:
- **Test Cases** (`ATP-NNN-X`) — logical validation conditions
- **User Scenarios** (`SCN-NNN-X#`) — BDD Given/When/Then executable steps

Validates 100% coverage via deterministic script (not AI self-assessment).

#### 3. Build Traceability Matrix (Step 7)

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
