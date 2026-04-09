---
title: Contributing Guide
description: How to contribute to the V-Model Extension Pack for Spec Kit — development setup, project structure, testing requirements, coding conventions, and the pull request process.
---

# Contributing Guide

Thank you for your interest in contributing to the **V-Model Extension Pack**! Whether you're fixing a bug, adding a feature, improving documentation, or writing tests — every contribution is valued.

!!! tip "Ways to contribute"

    - 🐛 **Bug reports** — found something broken? [Open an issue](https://github.com/leocamello/spec-kit-v-model/issues/new?template=bug_report.md)
    - 💡 **Feature requests** — have an idea? [Suggest it](https://github.com/leocamello/spec-kit-v-model/issues/new?template=feature_request.md)
    - 📝 **Documentation** — typos, clarifications, examples
    - 🧪 **Tests** — expand coverage across BATS, Pester, or evals
    - 🔧 **Code** — new commands, script improvements, validators

## Development Setup

### Prerequisites

- [Spec Kit](https://github.com/github/spec-kit) v0.1.0+ (Python ≥ 3.11)
- Git
- Bash (Linux/macOS) or PowerShell (Windows)

### Getting Started

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

## Project Structure

```
spec-kit-v-model/
├── commands/               # Slash command definitions (14 AI prompts)
├── templates/              # Output file templates for generated artifacts
├── scripts/
│   ├── bash/               # Helper scripts (Linux/macOS) — 13 scripts
│   ├── powershell/         # Helper scripts (Windows) — 13 scripts
│   └── python/             # Python helper scripts
├── tests/
│   ├── bats/               # BATS-core Bash unit tests (364 tests)
│   ├── pester/             # Pester PowerShell unit tests (347 tests)
│   ├── fixtures/           # Shared test data & golden examples
│   └── evals/              # DeepEval prompt evaluations (89 structural + 42 LLM)
├── docs/                   # Additional documentation
├── .github/
│   ├── agents/             # Agent definitions for all 14 commands
│   └── workflows/          # CI and evaluation pipelines
├── extension.yml           # Extension manifest
├── config-template.yml     # Configuration template
└── pyproject.toml          # Python project config (pytest, deepeval)
```

## How to Add a New Command

This project uses its own V-Model extension for development. When adding a new feature, follow this spec-driven workflow:

1. **Specify** — `/speckit.specify <description>` creates a feature branch and `spec.md` with user stories and requirements.
2. **Requirements** — `/speckit.v-model.requirements` atomizes the spec into traceable `REQ-NNN` identifiers.
3. **Acceptance** — `/speckit.v-model.acceptance` generates paired test cases (`ATP`) and BDD scenarios (`SCN`) with 100% coverage validation.
4. **Design** — Walk down the V-Model levels as needed:
    - `/speckit.v-model.system-design` → system-level components (`SYS-NNN`)
    - `/speckit.v-model.architecture-design` → architecture elements (`ARCH-NNN`)
    - `/speckit.v-model.module-design` → module-level designs (`MOD-NNN`)
5. **Test Plans** — Generate paired test plans at each level:
    - `/speckit.v-model.system-test` → system test procedures (`STP`)
    - `/speckit.v-model.integration-test` → integration test procedures (`ITP`)
    - `/speckit.v-model.unit-test` → unit test procedures (`UTP`)
6. **Trace** — `/speckit.v-model.trace` builds the traceability matrix at each level (Matrix A + B + C + D).
7. **Implement** — Use spec-kit core (`/speckit.plan`, `/speckit.tasks`, `/speckit.implement`) to execute the design.
8. **Verify** — Run validation scripts and tests to ensure coverage.

All artifacts live in `specs/{feature}/`. See the [README](https://github.com/leocamello/spec-kit-v-model#proactive-workflow-recommended) for a detailed walkthrough.

## Testing Requirements

The project has a comprehensive test suite across four layers. **All tests must pass before a PR can be merged.**

### Test Architecture

| Layer | Framework | Tests | What It Validates |
|-------|-----------|------:|-------------------|
| **BATS** | bats-core | 364 | Bash script logic: setup, coverage validation, impact analysis, matrix building, diff detection, peer review check, test result ingestion, audit report building |
| **Pester** | Pester 5 | 347 | PowerShell script parity with Bash — identical behavior across platforms |
| **Structural evals** | pytest + DeepEval | 89 | ID format/hierarchy, template conformance, BDD scenario completeness, impact analysis graph properties |
| **LLM evals** | pytest + DeepEval GEval | 42 | Requirements quality (IEEE 29148), BDD quality, traceability completeness |

### Running Tests

=== "BATS (Bash)"

    ```bash
    tests/bats/lib/bats-core/bin/bats tests/bats/*.bats
    ```

=== "Pester (PowerShell)"

    ```powershell
    Invoke-Pester tests/pester/ -CI
    ```

=== "Structural Evals (Python)"

    ```bash
    pip install -e ".[dev]"
    pytest tests/evals/ -m structural -v
    ```

=== "LLM Evals"

    ```bash
    GOOGLE_API_KEY=... pytest tests/evals/ -m eval -v
    ```

### Adding Tests

- **New BATS test** — Add to `tests/bats/` following existing patterns. Use `test_helper.bash` for fixtures.
- **New Pester test** — Mirror the BATS test in `tests/pester/` for PowerShell parity.
- **New eval test** — Add to `tests/evals/test_*_eval.py`. Mark with `@pytest.mark.structural` (deterministic) or `@pytest.mark.eval` (LLM).
- **New fixture** — Add directory under `tests/fixtures/` with V-Model fixture files.

### CI Pipelines

- **`ci.yml`** — Runs on every push/PR: BATS tests + structural validators (Ubuntu), Pester tests (Windows)
- **`evals.yml`** — Structural evals run weekly; LLM evals run on manual dispatch

## Coding Conventions

### Command Files (`commands/*.md`)

Commands are AI prompts, not executable code:

- Be precise with instructions — the AI follows them literally
- Reference JSON keys exactly as the setup script outputs them (e.g., `VMODEL_DIR`)
- Delegate deterministic tasks to scripts — never ask the AI to count or validate coverage
- Include examples of expected input/output

### Helper Scripts (`scripts/`)

Scripts handle all deterministic logic:

- **Maintain parity** between Bash and PowerShell — both must produce identical output
- **Use the base-key matching pattern** for ID cross-referencing (see `req_base_key()` / `atp_base_key()`)
- **Output JSON** when `--json` flag is passed — match existing key names exactly
- **Test with category prefixes** — always verify with `REQ-NF-001`, `REQ-IF-001`, etc.

### ID Schema

The four-tier ID schema is a core architectural decision. Any changes must preserve:

- **Self-documenting lineage**: `SCN-001-A1` → `ATP-001-A` → `REQ-001`
- **Category prefix support**: `REQ-NF-001`, `ATP-NF-001-A`, `SCN-NF-001-A1`
- **Permanent IDs**: Never renumber — gaps are acceptable

### Templates (`templates/`)

Keep templates minimal, consistent with the ID schema, and documented with HTML comments.

## Pull Request Process

1. **Create a branch** from `main`:

    ```bash
    git checkout -b your-feature-name
    ```

2. **Make your changes** — follow the guidelines above.

3. **Test your changes** — run the relevant test suites.

4. **Commit** with a descriptive message:

    ```bash
    git commit -m "Add support for custom ID prefixes in validate-requirement-coverage"
    ```

5. **Push and open a Pull Request** against `main`.

!!! info "What reviewers look for"

    - All existing tests pass
    - New code has corresponding tests
    - Bash/PowerShell parity is maintained for script changes
    - ID schema conventions are followed
    - Documentation is updated if behavior changes

## Related Pages

- [Code of Conduct](code-of-conduct.md) — Community standards and expectations
- [Security Policy](security.md) — How to report vulnerabilities
- [Changelog](changelog.md) — Version history and release notes
- [Roadmap](roadmap.md) — What's coming next

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](https://github.com/leocamello/spec-kit-v-model/blob/main/LICENSE).
