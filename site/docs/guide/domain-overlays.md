---
title: Domain Overlay Architecture
description: How domain-specific safety content is decoupled from base V-Model commands and loaded at runtime for regulated industries.
---

# Domain Overlay Architecture

The Domain Overlay Architecture separates universal best-practice standards from domain-specific regulatory content — so non-safety projects run clean, and safety-critical projects get precisely the right domain content without cross-contamination.

---

## The Problem

Before v0.6.0, all 14 base commands embedded ISO 26262 / DO-178C / IEC 62304 safety content directly in their instructions. This caused three problems:

**Framing leaks** — Commands opened with phrases like "DO-178C/ISO 26262-compliant low-level module designs," making every output look like it was produced for a safety-critical project, even when the user was building a non-regulated web application.

**Reference material bloat** — Safety standards tables (ASIL severity grids, DAL coverage matrices, SIL requirement sets) appeared in every output. For teams not subject to those standards, this was noise that obscured the useful content.

**Cross-domain contamination** — An IEC 62304 (medical device) project running the `architecture-design` command received ISO 26262 ASIL decomposition instructions alongside DO-178C temporal constraint instructions. Both sets of safety content fired unconditionally, regardless of the configured domain. A medical device team had to manually filter out automotive and aerospace regulatory content from every design artifact.

---

## The Solution

The Domain Overlay Architecture removes all domain-specific safety content from the base commands and places it in per-domain overlay files that are loaded at runtime.

```
                    ┌──────────────────────┐
                    │   Base Command       │
                    │  (best practice only)│
                    │  - IEEE 29148        │
                    │  - ISO/IEC 25010     │
                    │  - IEEE 1016         │
                    └──────────┬───────────┘
                               │
                    domain: iso_26262?
                               │
                    ┌──────────▼───────────┐
                    │   Overlay File        │
                    │  iso_26262/system-    │
                    │  design.md           │
                    │  - FFI Analysis      │
                    │  - ASIL Decomp       │
                    │  - Restricted        │
                    │    Complexity        │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
                    │  Assembled Command   │
                    │  (base + domain)     │
                    └──────────────────────┘
```

When `domain:` is empty, only the base command runs. When a domain is configured, the matching overlay is merged in — no other domain's content is ever loaded.

---

## How It Works

The assembly protocol runs at the start of each command's System Prompt:

**Step 1 — Read configuration**

The command reads `v-model-config.yml` from the repository root and extracts the `domain:` field.

```yaml
# v-model-config.yml
domain: "iso_26262"
```

**Step 2 — Locate overlay directory**

The command resolves the overlay path: `commands/overlays/{domain}/`

**Step 3 — Load `_domain.yml` manifest**

Each domain directory contains a `_domain.yml` manifest describing the domain:

```yaml
# commands/overlays/iso_26262/_domain.yml
display_name: "ISO 26262 (Automotive)"
standard: "ISO 26262:2018"
classification_system:
  name: "ASIL"
  levels: ["QM", "ASIL A", "ASIL B", "ASIL C", "ASIL D"]
overlay_commands:
  - requirements
  - acceptance
  - system-design
  ...
```

**Step 4 — Inject domain-specific instructions**

The command loads its matching overlay file (e.g., `commands/overlays/iso_26262/requirements.md`) and injects the domain-specific sections into the relevant parts of its instruction set.

**Step 5 — Generate merged output**

The assembled command produces output containing both best-practice content (from the base) and domain-specific content (from the overlay). The two layers are clearly separated in the output.

---

## Overlay Directory Structure

```
commands/overlays/
├── iso_26262/
│   ├── _domain.yml              ← manifest: domain name, classification, applicable commands
│   ├── requirements.md          ← ASIL allocation, derived safety requirements, safety mechanisms
│   ├── acceptance.md            ← ASIL-dependent verification methods (Table 11)
│   ├── system-design.md         ← FFI Analysis, Restricted Complexity, safety mechanisms
│   ├── system-test.md           ← MC/DC targets, WCET, structural coverage by ASIL
│   ├── architecture-design.md   ← ASIL Decomposition (Part 9 §5), Defensive Programming
│   ├── integration-test.md      ← SIL/HIL Compatibility, Resource Contention
│   ├── module-design.md         ← MISRA C/C++, Complexity Limits, Memory Management
│   ├── unit-test.md             ← MC/DC Coverage, Variable-Level Fault Injection
│   ├── hazard-analysis.md       ← HARA, ASIL severity classification (S×E×C)
│   ├── trace.md                 ← ASIL-dependent coverage requirements
│   ├── peer-review.md           ← Review rigor by ASIL level
│   ├── impact-analysis.md       ← Safety impact assessment, ASIL re-evaluation
│   ├── audit-report.md          ← Functional safety audit, confirmation measures
│   └── test-results.md          ← ASIL coverage metrics (Table 12)
├── do_178c/
│   ├── _domain.yml              ← manifest: DAL A–E classification system
│   ├── requirements.md          ← DAL traceability, derived requirements, robustness by DAL
│   ├── acceptance.md            ← Requirements-based testing, structural coverage by DAL
│   ├── system-design.md         ← Partitioning, data/control coupling, derived requirements
│   ├── system-test.md           ← Structural coverage analysis by DAL
│   ├── architecture-design.md   ← DAL-driven verification, partitioning requirements
│   ├── integration-test.md      ← Hardware fidelity by DAL, integration verification
│   ├── module-design.md         ← CERT-C, Single Entry/Exit, Complexity by DAL
│   ├── unit-test.md             ← Structural coverage by DAL, MC/DC for DAL A
│   └── ...                      ← hazard-analysis, trace, peer-review, impact-analysis, audit-report, test-results
└── iec_62304/
    ├── _domain.yml              ← manifest: Class A–C safety classification system
    ├── requirements.md          ← Safety class–dependent rigor, risk analysis input
    ├── acceptance.md            ← Safety class test completeness, regression
    ├── system-design.md         ← Architecture + risk control traceability
    ├── system-test.md           ← Testing by safety class
    ├── architecture-design.md   ← Architecture by safety class, interface documentation
    ├── integration-test.md      ← Integration testing by safety class
    ├── module-design.md         ← Detailed design by safety class, coding standards
    ├── unit-test.md             ← Verification by safety class, robustness testing
    └── ...                      ← hazard-analysis, trace, peer-review, impact-analysis, audit-report, test-results
```

**Total:** 36 overlay files (12 commands × 3 domains) + 3 `_domain.yml` manifests.

---

## Domain Coverage

| Domain | Standard | Classification System | Primary Focus |
|--------|----------|----------------------|---------------|
| `iso_26262` | ISO 26262:2018 | ASIL (QM, A, B, C, D) | Automotive functional safety — ASIL allocation, HARA, FFI |
| `do_178c` | DO-178C / ED-12C | DAL (E, D, C, B, A) | Aerospace software assurance — DAL-driven verification depth |
| `iec_62304` | IEC 62304:2006/AMD1:2015 | Safety Class (A, B, C) | Medical device software lifecycle — class-proportional rigor |

### What each domain adds to key commands

| Command | `iso_26262` | `do_178c` | `iec_62304` |
|---------|------------|-----------|-------------|
| `requirements` | ASIL allocation + decomposition, safety mechanisms | DAL traceability, derived requirements | Safety class rigor, risk analysis input |
| `system-design` | FFI Analysis, Restricted Complexity | Partitioning, data/control coupling | Risk control traceability |
| `architecture-design` | ASIL Decomposition, Defensive Programming | DAL-driven verification, partitioning | Architecture by safety class |
| `module-design` | MISRA C/C++, Complexity ≤ 10, Memory Management | CERT-C, Single Entry/Exit | Detailed design by safety class |
| `unit-test` | MC/DC Coverage, Variable-Level Fault Injection | Structural coverage by DAL | Verification by safety class |
| `hazard-analysis` | HARA, ASIL severity (S×E×C) | FHA via ARP 4761, failure condition classification | Software safety classification A–C |

---

## Non-Regulated Projects

When `domain:` is empty (or `v-model-config.yml` is absent), the extension operates in **pure best-practice mode**:

- All 17 commands produce output governed only by universal standards: IEEE 29148, ISO/IEC 25010, IEEE 1016, IEEE 42010, ISO 29119, IEC 60812, and the other 11 best-practice standards referenced across the command set
- The bridge commands (`plan`, `tasks`, `implement`) inherit overlay context indirectly: they consume artifacts already produced by the 11 base commands, so any domain-specific sections injected at generation time flow through to the planning, task decomposition, and implementation steps
- No ASIL tables, DAL classifications, or safety class constraints appear in any output
- The output is clean and directly relevant to non-regulated software projects
- You can still use hazard analysis (`IEC 60812:2018` FMEA) — risk thinking is valuable for any safety-relevant system, not just regulated ones

```yaml
# v-model-config.yml — non-regulated project (or omit the file entirely)
domain: ""
```

!!! tip "No config file needed"
    If you are not building for a regulated domain, you do not need `v-model-config.yml` at all. The extension works identically without it.

---

## Adding a New Domain

To add a new regulatory domain (e.g., IEC 61508 for industrial safety):

1. **Create the directory:** `commands/overlays/iec_61508/`
2. **Create `_domain.yml`** — specify the display name, standard reference, classification system (e.g., SIL 1–4), and list of applicable commands
3. **Create overlay files** for each applicable command — one `.md` file per command, containing only the domain-specific instructions to inject
4. **Update `config-template.yml`** — add `iec_61508` to the domain enum documentation
5. **Test the assembly** — run each command with `domain: iec_61508` and verify the domain-specific sections appear correctly

The overlay files contain only the incremental domain-specific content; the base command instructions are unchanged. This means a new domain requires writing only the delta, not rewriting the entire command.

!!! note "Contribution welcome"
    See the [Contributing Guide](../community/contributing.md) if you want to contribute a new domain overlay.
