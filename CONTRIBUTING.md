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
├── commands/           # Slash command definitions (AI prompts)
│   ├── requirements.md
│   ├── acceptance.md
│   └── trace.md
├── templates/          # Output file templates
├── scripts/
│   ├── bash/           # Helper scripts (Linux/macOS)
│   └── powershell/     # Helper scripts (Windows)
├── docs/               # Additional documentation
├── extension.yml       # Extension manifest
└── config-template.yml # Configuration template
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
   git commit -m "Add support for custom ID prefixes in validate-coverage"
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

### Manual Testing

1. Install the extension in a test project (see [Development Setup](#development-setup)).
2. Test helper scripts directly:

   ```bash
   # Setup
   bash scripts/bash/setup-v-model.sh --json

   # Validate coverage (requires requirements.md + acceptance-plan.md)
   bash scripts/bash/validate-coverage.sh --json specs/{feature}/v-model/

   # Build matrix
   bash scripts/bash/build-matrix.sh specs/{feature}/v-model/

   # Diff requirements
   bash scripts/bash/diff-requirements.sh specs/{feature}/v-model/
   ```

3. Verify category-aware matching:
   - Create test data with mixed categories (`REQ-001`, `REQ-NF-001`, `REQ-IF-001`).
   - Ensure scripts correctly distinguish between them.

### What to Verify

- [ ] All 4 Bash scripts run without errors
- [ ] All 4 PowerShell scripts produce identical output to Bash equivalents
- [ ] `setup-v-model.sh` resolves the correct repo root and feature directory
- [ ] `validate-coverage.sh` correctly identifies gaps for category-prefixed IDs
- [ ] `build-matrix.sh` generates a valid markdown table with no mismatched rows
- [ ] Extension installs and registers commands with `specify extension add --dev`

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
