# Contributing to V-Model Extension Pack

Thank you for your interest in contributing to the V-Model Extension Pack for Spec Kit! This document provides guidelines and instructions for contributing.

## Getting Started

### Prerequisites

- [Spec Kit](https://github.com/github/spec-kit) v0.1.0 or higher (Python ≥ 3.11)
- Git
- Bash (for running helper scripts on Linux/macOS) or PowerShell (for Windows)

### Development Setup

1. **Fork and clone the repository:**

   ```bash
   git clone https://github.com/<your-username>/spec-kit-v-model.git
   cd spec-kit-v-model
   ```

2. **Set up a test project:**

   ```bash
   mkdir test-project && cd test-project
   specify init --here
   ```

3. **Install the extension in development mode:**

   ```bash
   specify extension add --dev /path/to/spec-kit-v-model
   ```

4. **Verify the installation:**

   ```bash
   specify extension list
   ```

### Project Structure

```
spec-kit-v-model/
├── commands/               # Slash command definitions (AI prompts)
│   ├── requirements.md
│   ├── acceptance.md
│   └── trace.md
├── templates/              # Output file templates
├── scripts/
│   ├── bash/               # Helper scripts (Linux/macOS)
│   └── powershell/         # Helper scripts (Windows)
├── tests/
│   ├── bats/               # BATS-core bash unit tests (27 tests)
│   ├── pester/             # Pester PowerShell unit tests (27 tests)
│   ├── fixtures/           # Shared test data (5 sets + 2 golden examples)
│   ├── validators/         # Deterministic structural validators (Python)
│   └── evals/              # DeepEval prompt evaluations
│       ├── metrics/        # Custom eval metrics (structural + GEval)
│       ├── test_*_eval.py  # Eval test cases (15 structural + 6 LLM)
│       └── conftest.py     # Shared pytest fixtures
├── docs/                   # Additional documentation
├── extension.yml           # Extension manifest
├── config-template.yml     # Configuration template
├── pyproject.toml          # Python project config (pytest, deepeval)
└── .github/workflows/
    ├── ci.yml              # CI: BATS + Pester + structural validators
    └── evals.yml           # Evals: structural (weekly) + LLM (manual)
```

## How to Contribute

### Reporting Bugs

- Use the [Bug Report](https://github.com/leocamello/spec-kit-v-model/issues/new?template=bug_report.md) issue template.
- Include: steps to reproduce, expected behavior, actual behavior, and script output (if applicable).
- For script bugs, include the output of running the script with `bash -x` (verbose mode).

### Suggesting Features

- Use the [Feature Request](https://github.com/leocamello/spec-kit-v-model/issues/new?template=feature_request.md) issue template.
- Explain the use case and how it fits into the V-Model workflow.

### Submitting Changes

1. **Create a branch** from `main`:

   ```bash
   git checkout -b your-feature-name
   ```

2. **Make your changes** — follow the guidelines below.

3. **Test your changes** — see [Testing](#testing).

4. **Commit** with a descriptive message:

   ```bash
   git commit -m "Add support for custom ID prefixes in validate-requirement-coverage"
   ```

5. **Push and open a Pull Request** against `main`.

## Development Guidelines

### Command Files (`commands/*.md`)

Commands are AI prompts, not executable code. When editing them:

- **Be precise with instructions** — the AI will follow them literally.
- **Reference JSON keys exactly** as the setup script outputs them (e.g., `VMODEL_DIR`, not `v_model_dir`).
- **Delegate deterministic tasks to scripts** — never ask the AI to count, cross-reference, or validate coverage.
- **Include examples** of expected input/output for clarity.

### Helper Scripts (`scripts/`)

Scripts handle all deterministic logic (counting, cross-referencing, matrix building):

- **Maintain parity** between Bash and PowerShell versions — both must produce identical output.
- **Use the base-key matching pattern** for ID cross-referencing (see `req_base_key()` / `atp_base_key()` functions).
- **Output JSON** when `--json` flag is passed — match the existing key names exactly.
- **Test with category prefixes** — always verify with `REQ-NF-001`, `REQ-IF-001`, etc., not just `REQ-001`.

### ID Schema

The three-tier ID schema is a core architectural decision. Any changes must preserve:

- **Self-documenting lineage**: `SCN-001-A1` → `ATP-001-A` → `REQ-001`
- **Category prefix support**: `REQ-NF-001`, `ATP-NF-001-A`, `SCN-NF-001-A1`
- **Permanent IDs**: Never renumber — gaps are acceptable.

### Templates (`templates/`)

Templates define the structure of generated output files. Keep them:

- **Minimal** — just enough structure for the AI to follow.
- **Consistent** — match the ID schema and terminology used in commands.
- **Documented** — use HTML comments to explain sections the AI should fill.

## Testing

The project has a comprehensive test suite across three layers.

### Running Tests

```bash
# 1. BATS tests (Bash scripts — requires Linux/macOS)
tests/bats/lib/bats-core/bin/bats tests/bats/*.bats

# 2. Pester tests (PowerShell scripts — requires Windows/pwsh)
Invoke-Pester tests/pester/ -CI

# 3. Structural eval tests (Python — deterministic, no LLM)
pip install -e ".[dev]"
pytest tests/evals/ -m structural -v

# 4. LLM-as-judge eval tests (requires GOOGLE_API_KEY)
GOOGLE_API_KEY=... pytest tests/evals/ -m eval -v
```

### Test Architecture

| Layer | Framework | Tests | What it validates |
|-------|-----------|-------|-------------------|
| **BATS** | bats-core | 27 | Bash script logic: setup, coverage validation, matrix building, diff detection |
| **Pester** | Pester 5 | 27 | PowerShell script parity with Bash |
| **Structural evals** | pytest + DeepEval | 15 | ID format/hierarchy, template conformance, BDD scenario completeness |
| **LLM-as-judge evals** | pytest + DeepEval GEval | 6 | Requirements quality (IEEE 29148), BDD quality, traceability completeness |

### Test Fixtures

Test fixtures live in `tests/fixtures/` with 5 scenario sets plus 2 golden examples:

- **`minimal/`** — 3 REQs, full coverage (baseline happy path)
- **`gaps/`** — Intentional coverage gap (REQ-NF-001 has no ATP)
- **`complex/`** — 16 REQs across 4 categories + orphaned ATP-999-A
- **`empty/`** — Empty files for edge case testing
- **`malformed/`** — Broken ID formats
- **`golden/medical-device/`** — IEC 62304 blood glucose monitor (reference quality)
- **`golden/automotive-adas/`** — ISO 26262 emergency braking system (reference quality)

### Adding Tests

- **New BATS test**: Add to `tests/bats/` following existing patterns. Use `test_helper.bash` for fixtures.
- **New Pester test**: Mirror the BATS test in `tests/pester/` for PowerShell parity.
- **New eval test**: Add to `tests/evals/test_*_eval.py`. Mark with `@pytest.mark.structural` (deterministic) or `@pytest.mark.eval` (LLM).
- **New fixture**: Add directory under `tests/fixtures/` with `requirements.md` and `acceptance-plan.md`.

### CI Pipelines

- **`ci.yml`** — Runs on every push/PR: BATS tests + structural validators (Ubuntu), Pester tests (Windows)
- **`evals.yml`** — Structural evals run weekly; LLM evals run on manual dispatch with `GOOGLE_API_KEY` secret

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
