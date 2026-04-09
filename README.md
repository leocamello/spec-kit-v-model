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

> **The AI drafts. The human decides. The scripts verify. Git remembers.**

## Why

AI-native teams ship fast but produce no traceability. Regulated teams have full traceability but move too slowly. The V-Model Extension Pack closes this gap — from a single specification, it generates traceable requirements, paired test plans, hazard analysis, and a deterministic traceability matrix in minutes, not months.

## Features

| Category | Commands |
|----------|----------|
| **Specification** | `requirements` · `system-design` · `architecture-design` · `module-design` |
| **Test Planning** | `acceptance` · `system-test` · `integration-test` · `unit-test` |
| **Cross-Cutting** | `hazard-analysis` · `impact-analysis` · `peer-review` |
| **Verification** | `trace` · `test-results` · `audit-report` |

**14 commands** across 4 V-Model levels, with deterministic coverage validation, 5 traceability matrices (A–D + H), and compliance gating for regulated industries.

## Quick Start

```bash
# Install the extension
specify extension add v-model \
  --from https://github.com/leocamello/spec-kit-v-model/archive/refs/tags/v0.5.0.zip

# Generate requirements from your spec
/speckit.v-model.requirements

# Generate paired acceptance tests (100% coverage validated by script)
/speckit.v-model.acceptance

# Build the traceability matrix
/speckit.v-model.trace
```

That's Level 1. Go deeper with `system-design` → `system-test` → `architecture-design` → `integration-test` → `module-design` → `unit-test`, running `trace` after each pair.

## Built for Regulated Industries

| Standard | Domain | Use Case |
|----------|--------|----------|
| **IEC 62304** | Medical Devices | Software safety classes A/B/C |
| **ISO 26262** | Automotive | ASIL A–D functional safety |
| **DO-178C** | Aerospace | DAL A–E design assurance |

Configure your domain in `v-model-config.yml`:

```yaml
domain: iec_62304  # or iso_26262, do_178c
```

## The Core Principle

Scripts handle all deterministic logic — coverage calculations, matrix generation, gap detection. AI handles creative translation — turning specifications into structured requirements and test scenarios. Humans review every artifact. Git remembers everything.

| What | Who |
|------|-----|
| Generate requirements & test plans | AI + Human review |
| Coverage calculation & matrix generation | Deterministic scripts |
| Quality evaluation | LLM-as-judge (advisory) |
| Audit trail | Git (cryptographic hashes) |

## Testing

| Layer | Tests | What it validates |
|-------|-------|-------------------|
| BATS | **364** | Bash script logic across 14 test files |
| Pester | **347** | PowerShell script parity |
| Structural | **89** | ID format, template conformance, section completeness |
| LLM evals | **42** | Requirements quality, BDD quality, traceability |

## 📖 Documentation

**Full documentation, tutorials, and guides are available at the [project website](https://leocamello.github.io/spec-kit-v-model/).**

- [Getting Started](https://leocamello.github.io/spec-kit-v-model/getting-started/) — Install and create your first V-Model project in 15 minutes
- [Guides](https://leocamello.github.io/spec-kit-v-model/guide/concepts/) — V-Model concepts, level-by-level guides, CI integration
- [Compliance](https://leocamello.github.io/spec-kit-v-model/compliance/) — IEC 62304, ISO 26262, DO-178C artifact mapping
- [Tutorials](https://leocamello.github.io/spec-kit-v-model/tutorials/medical-device/) — End-to-end walkthroughs for medical, automotive, and aerospace
- [Reference](https://leocamello.github.io/spec-kit-v-model/reference/commands/) — All 14 commands, ID schema, scripts, templates, configuration
- [Contributing](CONTRIBUTING.md) — Development setup, testing, PR process

## License

[MIT](LICENSE)
