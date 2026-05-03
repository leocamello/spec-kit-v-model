---
title: Getting Started
description: Get up and running with the V-Model Extension Pack for Spec Kit — install the extension, configure your domain, and generate your first audit-ready requirements in minutes.
---

# Getting Started

Welcome to the **V-Model Extension Pack** for [Spec Kit](https://github.com/github/spec-kit)! This guide will take you from zero to audit-ready requirements with full traceability.

## What You'll Learn

<div class="grid cards" markdown>

-   :material-download:{ .lg .middle } **Installation** (~5 minutes)

    ---

    Install the extension from the catalog, a GitHub release, or a local clone — then configure your regulatory domain.

    [:octicons-arrow-right-24: Installation Guide](installation.md)

-   :material-rocket-launch:{ .lg .middle } **Your First V-Model Project** (~15 minutes)

    ---

    Create requirements, generate acceptance tests, and build a traceability matrix — all from a single spec.

    [:octicons-arrow-right-24: First Project Tutorial](first-project.md)

</div>

## Prerequisites

Before you begin, make sure you have the following installed:

| Prerequisite | Minimum Version | Notes |
|---|---|---|
| [Spec Kit](https://github.com/github/spec-kit) | v0.1.0+ | The core `specify` CLI must be installed and on your `PATH` |
| [Python](https://www.python.org/) | ≥ 3.11 | Required by Spec Kit |
| [Git](https://git-scm.com/) | Any recent version | For version control and extension installation |
| **Shell** | — | Bash (Linux/macOS) or PowerShell (Windows) |

!!! tip "Check your Spec Kit version"

    ```bash
    specify --version
    ```

    If you don't have Spec Kit yet, follow the [Spec Kit installation instructions](https://github.com/github/spec-kit) first.

## How These Guides Are Organized

1. **[Installation](installation.md)** — Three ways to install, plus optional domain configuration for regulated industries.
2. **[Your First V-Model Project](first-project.md)** — A hands-on tutorial covering Level 1 of the V-Model (Requirements ↔ Acceptance Testing).

## Bridge to Implementation

Once your V-Model artifacts are in place (requirements through unit tests, plus the trace matrix), the **bridge commands** introduced in v0.7.0 carry them forward into deterministic, gated implementation:

```
/speckit.v-model.plan       →  plan.md (V-Model-enriched, schema-validated)
/speckit.v-model.tasks      →  tasks.md (TDD-ordered, with `Implements` headers)
/speckit.v-model.implement  →  source + tests + hallucination guard + trace post-hook
```

Every step runs `run-v-model-gate.sh` (the 8-stage pipeline `status → domain → matrix → 5 coverage validators`) and the deterministic `Implements`-directive hallucination guard. Artifacts under `specs/<feature>/v-model/` must carry `**Status**: Approved` (enforced by `validate-artifact-status.sh` since v0.7.0).

!!! warning "Compliant vs. hybrid mode"
    It is technically possible to feed a V-Model `tasks.md` to **core** `/speckit.implement`. That hybrid path bypasses the V-Model gates, the hallucination guard, and the trace post-hook — use it only for prototyping. See the [Bridge Commands guide](../guide/bridge-commands.md) for the canonical compliant-vs-hybrid distinction.

Once you've completed the first project tutorial, explore the deeper V-Model levels in the [Guides](../guide/concepts.md) section and follow the [Bridge Commands guide](../guide/bridge-commands.md) to ship code from your verified specifications.
