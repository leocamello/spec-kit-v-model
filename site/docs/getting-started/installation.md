---
title: Installation
description: Install the V-Model Extension Pack for Spec Kit from the catalog, a GitHub release, or a local clone, and configure your regulatory domain.
---

# Installation

The V-Model Extension Pack can be installed in three ways depending on your use case. All methods take under five minutes.

## Install the Extension

### Method 1: From the Catalog

!!! note "Coming soon"

    Catalog installation will be available once Spec Kit's extension catalog launches. Use Method 2 or 3 in the meantime.

```bash
specify extension add v-model
```

### Method 2: From a GitHub Release

Install a specific release directly from GitHub:

```bash
specify extension add v-model \
  --from https://github.com/leocamello/spec-kit-v-model/archive/refs/tags/v0.5.0.zip
```

!!! tip "Pinning a version"

    Replace `v0.5.0` in the URL with the [release tag](https://github.com/leocamello/spec-kit-v-model/releases) you want. Pinning ensures reproducible builds across your team.

### Method 3: From a Local Directory (Development)

Clone the repository, then install in development mode:

=== "Bash"

    ```bash
    git clone https://github.com/leocamello/spec-kit-v-model.git
    specify extension add --dev /path/to/spec-kit-v-model
    ```

=== "PowerShell"

    ```powershell
    git clone https://github.com/leocamello/spec-kit-v-model.git
    specify extension add --dev C:\path\to\spec-kit-v-model
    ```

!!! tip "Development mode"

    The `--dev` flag creates a symlink instead of copying files. Changes you make to the extension source are immediately available — no reinstall needed.

## Verify Installation

Confirm the extension is installed and recognized:

```bash
specify extension list
```

You should see `v-model` in the output with version `0.5.0` (or whichever version you installed).

## Optional Configuration

### Domain Configuration

The V-Model Extension Pack works out of the box for non-regulated projects. If you're working in a **safety-critical domain**, create a `v-model-config.yml` file in your repository root to enable additional regulatory sections.

```yaml title="v-model-config.yml"
# Regulated domain identifier (optional)
domain: ""
```

### Available Domains

| Value | Standard | What It Enables |
|---|---|---|
| `""` (empty) | None | Default — clean output with no safety-critical sections |
| `iso_26262` | ISO 26262 (Automotive) | FFI analysis, ASIL decomposition, MC/DC coverage targets, MISRA/CERT-C annotations |
| `do_178c` | DO-178C (Aerospace) | FFI analysis, temporal constraints, MC/DC coverage targets, single entry/exit enforcement |
| `iec_62304` | IEC 62304 (Medical Devices) | FFI analysis, ASIL decomposition, MC/DC coverage targets, complexity limits |

### What Each Domain Adds

When a domain is set, V-Model commands generate **additional safety-critical sections** at every level of the V:

- **System Design** — Freedom from Interference (FFI) analysis and restricted complexity
- **System Test** — Structural coverage (MC/DC) targets and resource usage testing (WCET, stack, heap)
- **Architecture Design** — ASIL/DAL decomposition and defensive programming requirements
- **Integration Test** — SIL/HIL compatibility scenarios and resource contention testing
- **Module Design** — Cyclomatic complexity limits (≤ 10), memory management constraints, and coding standard annotations
- **Unit Test** — MC/DC coverage and variable-level fault injection

!!! warning "Choosing a domain is a project-level decision"

    The `v-model-config.yml` file should be committed to version control. Changing the domain mid-project will affect all subsequently generated artifacts. Use the [`/speckit.v-model.impact-analysis`](../reference/commands.md) command to assess the blast radius of any configuration change.

### Example: Automotive Project

```yaml title="v-model-config.yml"
domain: "iso_26262"
```

This single line adds ISO 26262-specific sections to every V-Model command output — no other configuration needed.

## Next Steps

You're installed and configured. Time to build something:

[Your First V-Model Project :material-arrow-right:](first-project.md){ .md-button .md-button--primary }
