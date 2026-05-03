# Tests Index

This directory contains the four-stack test corpus for the spec-kit-v-model
extension. Each subtree maps to one V-Model verification plan (UTP / ITP / STP /
ATP) under `specs/<feature>/v-model/`.

| Subtree | Stack | Source plan(s) |
| --- | --- | --- |
| `tests/bats/` | Unit (POSIX shell) | `specs/<feature>/v-model/unit-test.md` (UTP-NNN-A) |
| `tests/pester/` | Unit (PowerShell mirrors per D-009) | `specs/<feature>/v-model/unit-test.md` (UTP-NNN-A, PowerShell parity) |
| `tests/evals/` | Unit (LLM-as-judge per D-010) | `specs/<feature>/v-model/unit-test.md` (UTP-NNN-A for prompt-section MODs) |
| `tests/integration/` | Integration (cross-script wiring) | `specs/<feature>/v-model/integration-test.md` (ITP-NNN-A) |
| `tests/system/` | System (end-to-end CLI) | `specs/<feature>/v-model/system-test.md` (STP-NNN-A) |
| `tests/acceptance/` | Acceptance (user-facing scenarios) | `specs/<feature>/v-model/acceptance-plan.md` (ATP-NNN-A / SCN-NNN-A1) |
| `tests/fixtures/` | Shared corpora (V-Model artefact sets, malformed inputs, golden outputs) | n/a |
| `tests/helpers/` | Cross-language test helpers (canonical-ID extractor, etc.) | n/a |

## Conventions

- Every BATS file starts with `load "test_helper"` and a `# Implements: <IDs>` header.
- Every Pester file mirrors a BATS file 1:1 per D-009.
- Every eval file pins its DeepEval metric and structural assertions per D-010.
- Fixtures under `tests/fixtures/v-model/` mirror the canonical artefact set
  enumerated in `specs/<feature>/v-model/`.

## Running

```sh
# Unit (POSIX shell)
./tests/bats/lib/bats-core/bin/bats tests/bats/

# Integration / system / acceptance shells (currently scaffolds; populated as features land)
./tests/bats/lib/bats-core/bin/bats tests/integration/ tests/system/ tests/acceptance/

# PowerShell parity (Windows / pwsh)
Invoke-Pester tests/pester/ -CI

# Structural + LLM-as-judge evals (Python)
pytest tests/evals/ -m structural -v
GOOGLE_API_KEY=... pytest tests/evals/ -m eval -v
```
