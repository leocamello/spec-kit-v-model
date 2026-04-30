# spec-kit-v-model Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-05-01

## Active Technologies

- Python 3.11 (per existing `src/` module convention; all 27 `MOD-NNN` Target Source Files are `.py` — Source: module-design.md §Module Map) + `pathlib`, `re`, `subprocess`, `yaml` (stdlib only for deterministic modules); existing BATS, Pester, pytest+DeepEval test stacks (Source: constitution.md §Testing Stack) (007-bridge-commands)

## Project Structure

```text
src/
tests/
```

## Commands

cd src [ONLY COMMANDS FOR ACTIVE TECHNOLOGIES][ONLY COMMANDS FOR ACTIVE TECHNOLOGIES] pytest [ONLY COMMANDS FOR ACTIVE TECHNOLOGIES][ONLY COMMANDS FOR ACTIVE TECHNOLOGIES] ruff check .

## Code Style

Python 3.11 (per existing `src/` module convention; all 27 `MOD-NNN` Target Source Files are `.py` — Source: module-design.md §Module Map): Follow standard conventions

## Recent Changes

- 007-bridge-commands: Added Python 3.11 (per existing `src/` module convention; all 27 `MOD-NNN` Target Source Files are `.py` — Source: module-design.md §Module Map) + `pathlib`, `re`, `subprocess`, `yaml` (stdlib only for deterministic modules); existing BATS, Pester, pytest+DeepEval test stacks (Source: constitution.md §Testing Stack)

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
