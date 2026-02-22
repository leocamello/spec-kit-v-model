## Description

Brief description of what this PR does.

**Related Issue:** Fixes #

## Type of Change

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Changes Made

- 

## Checklist

### General
- [ ] My changes follow the project's [contributing guidelines](CONTRIBUTING.md)
- [ ] I have performed a self-review of my changes
- [ ] I have updated documentation (if applicable)
- [ ] I have updated the CHANGELOG.md (if applicable)

### Commands (`commands/*.md`)
- [ ] JSON key references match actual script output (e.g., `VMODEL_DIR`, not `v_model_dir`)
- [ ] Deterministic tasks are delegated to scripts, not AI self-assessment
- [ ] Examples in the prompt use the correct ID schema

### Scripts (`scripts/`)
- [ ] Bash and PowerShell versions produce identical output
- [ ] Category-prefixed IDs are handled correctly (REQ-NF-001, REQ-IF-001, etc.)
- [ ] JSON output mode (`--json`) matches documented key names
- [ ] Tested with mixed-category test data

### Testing
- [ ] Extension installs with `specify extension add --dev`
- [ ] All 4 Bash scripts run without errors
- [ ] `validate-requirement-coverage.sh` correctly detects gaps for category-prefixed IDs
- [ ] `build-matrix.sh` generates a valid traceability matrix
