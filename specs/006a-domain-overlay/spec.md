# Feature 006a: Domain Overlay Architecture

## Problem Statement

The spec-kit-v-model extension currently mixes safety-standard and domain-specific content directly into base commands and templates. This means that when a team working on a non-regulated project (e.g., a SaaS dashboard, a mobile app) runs the V-Model pipeline, they encounter ISO 26262 ASIL tables, DO-178C coverage requirements, and "regulatory-grade" language that is irrelevant to their work. Conversely, teams working in a specific domain (e.g., automotive only) see references to competing standards (e.g., DO-178C aviation terminology in what should be an ISO 26262-only workflow).

The root cause is that domain-specific content was added incrementally during v0.1.0–v0.5.0 development without a systematic separation mechanism. Some commands added conditional checks (`if domain is set in v-model-config.yml`), but the implementation is inconsistent: some commands have no domain check at all, others have checks but still leak domain terminology in descriptions and section headers, and the `config-template.yml` doesn't even expose a `domain` field yet.

### Current State Audit (Verified)

A file-by-file audit of all 14 commands, 12 templates, and key metadata files reveals the scope of contamination:

#### Commands (14 files in `commands/`)

| Command | Classification | Domain Check | Key Issues |
|---------|---------------|--------------|------------|
| `requirements.md` | **CLEAN** | None needed | No domain content |
| `acceptance.md` | **CLEAN** | None needed | No domain content |
| `impact-analysis.md` | **CLEAN** | None needed | Pure deterministic graph traversal |
| `test-results.md` | **CLEAN** | None needed | JUnit XML ingestion, domain-agnostic |
| `audit-report.md` | **CLEAN** (minor) | None needed | Example shows `--regulatory-context "IEC 62304"` but non-blocking |
| `system-design.md` | **MIXED** | ✅ Lines 54–55 | Safety section headers (Freedom from Interference, ASIL) visible in outline even when skipped |
| `system-test.md` | **MIXED** | ✅ Lines 59–60 | MC/DC mentioned unconditionally; ASIL/DAL hardcoded at line 182 |
| `architecture-design.md` | **MIXED** | ✅ Lines 64–65 | "ASIL Decomposition" header; ASIL field names hardcoded in tables |
| `integration-test.md` | **MIXED** | ✅ Lines 61–62 | SIL/HIL terminology; ISO 26262/DO-178C in section headers |
| `module-design.md` | **MIXED** | ✅ Lines 61–62 | Description hardcodes "DO-178C/ISO 26262-compliant"; MISRA/CERT-C in section titles |
| `unit-test.md` | **MIXED** | ✅ Lines 63–64 | MC/DC and Variable-Level Fault Injection listed unconditionally; hardware interface section not gated |
| `trace.md` | **HARDCODED** | ❌ None | "regulatory-grade" in description; 5 safety standards (DO-178C, ISO 26262, IEC 62304, FDA 21 CFR 820, IEC 61508) listed unconditionally in Goal and Operating Constraints sections |
| `hazard-analysis.md` | **HARDCODED** | Partial (lines 74–77) | "ISO 14971/ISO 26262-compliant" in description; severity tables hardcode 3 domain-specific scales; entire command is inherently safety-domain-specific |
| `peer-review.md` | **HARDCODED** | ❌ None | Governing Standard mapping table lists DO-178C, ISO 26262, ISO 14971 unconditionally; section headers embed safety standard names |

**Summary: 5 CLEAN, 6 MIXED (have conditionals but leak), 3 HARDCODED (no conditionals or inherently domain-specific).**

#### Templates (12 files in `templates/`)

| Template | Classification | Gate Pattern |
|----------|---------------|-------------|
| `acceptance-plan-template.md` | **CLEAN** | — |
| `audit-report-template.md` | **CLEAN** | — |
| `peer-review-template.md` | **CLEAN** | — |
| `requirements-template.md` | **CLEAN** | — |
| `traceability-matrix-template.md` | **CLEAN** | — |
| `architecture-design-template.md` | **GATED** | `<!-- SAFETY-CRITICAL SECTION -->` at line 131 |
| `hazard-analysis-template.md` | **GATED** | `<!-- DOMAIN-SPECIFIC SCALES -->` at line 41 |
| `integration-test-template.md` | **GATED** | `<!-- SAFETY-CRITICAL SECTION -->` at line 131 |
| `module-design-template.md` | **GATED** | `<!-- SAFETY-CRITICAL SECTION -->` at line 151 |
| `system-design-template.md` | **GATED** | `<!-- SAFETY-CRITICAL SECTION -->` at line 111 |
| `system-test-template.md` | **GATED** | `<!-- SAFETY-CRITICAL SECTION -->` at line 101 |
| `unit-test-template.md` | **GATED** | `<!-- SAFETY-CRITICAL TECHNIQUES -->` line 37, `<!-- SAFETY-CRITICAL SECTION -->` line 218 |

**Summary: 5 CLEAN, 7 GATED (safety content behind HTML comment markers — already well-structured). No HARDCODED templates.**

#### Metadata Files

| File | Issues |
|------|--------|
| `extension.yml` | 9 command descriptions reference safety standards unconditionally (IEEE 1016, ISO 29119, ISO 29119-4, IEEE 42010, DO-178C, ISO 26262, ISO 14971); "regulatory-grade" on line 75; `safety-critical` tag on line 95 |
| `config-template.yml` | **No `domain` field exists** — the conditional checks in commands reference a field that users cannot currently set |
| `README.md` | References "regulated teams" in project description (appropriate for project positioning, not a contamination issue) |

### Why This Matters

1. **Adoption barrier** — Teams evaluating spec-kit-v-model for non-regulated projects see safety jargon throughout and conclude the tool is "only for automotive/medical." The extension should present a clean, standards-based V-Model experience by default, with domain-specific enrichment available on demand.

2. **Domain mixing** — An automotive team (ISO 26262) sees DO-178C (aviation) terminology in their workflow. A medical team (IEC 62304) sees ASIL classifications. Each domain has its own vocabulary and classification systems; mixing them creates confusion.

3. **Config gap** — Six commands check for a `domain` field in `v-model-config.yml`, but that field doesn't exist in `config-template.yml`. Users have no documented way to activate or deactivate domain-specific behavior.

4. **Inconsistent patterns** — Templates use a clean HTML-comment gating pattern that works well. Commands use a verbal instruction pattern ("If `domain` is set... skip...") that is inconsistently applied and still leaks domain vocabulary into visible text. There is no single, reusable mechanism.

### User Experience Guarantee: Reduction, Not Addition

This feature is a **simplification**. It removes noise from the default experience rather than adding new complexity:

- **Before (v0.5.0):** A non-regulated team runs `/speckit.v-model.system-design` and sees "Freedom from Interference (ISO 26262-6 §7.4.8)" and ASIL rating tables in the output. They don't know what ASIL means and shouldn't have to. An automotive team runs `/speckit.v-model.module-design` and sees "DO-178C Level A" aviation terminology mixed in with their ISO 26262 workflow.

- **After (v0.6.0):** A non-regulated team runs the same command and sees clean, standards-based system design guidance with no safety jargon. An automotive team sets `domain: iso_26262` once and gets a workflow that speaks exclusively in ISO 26262 vocabulary — ASIL ratings, Freedom from Interference, MISRA-C — with no aviation or medical terminology leaking in.

- **Zero-config default:** If a user never touches `v-model-config.yml`, everything works and no domain content appears. The extension presents a clean V-Model methodology based on universally applicable standards (IEEE 1016, ISO 29119, IEEE 42010, INCOSE).

- **One-field activation:** Setting `domain: iso_26262` enriches every applicable command and template with automotive-specific content. One configuration change, consistent enrichment everywhere.

## Proposed Solution

Introduce a **file-based domain overlay architecture** that cleanly separates base (domain-agnostic) content from domain-specific enrichment layers. The architecture follows an additive composition model: overlays ADD content after base commands/templates, never replacing them.

### Architecture Overview

```
commands/                          templates/
├── requirements.md       (base)   ├── requirements-template.md       (base)
├── system-design.md      (base)   ├── system-design-template.md      (base)
├── ...                            ├── ...
└── overlays/                      └── overlays/
    ├── iso_26262/                     ├── iso_26262/
    │   ├── _domain.yml                │   ├── system-design-overlay.md
    │   ├── system-design.md           │   ├── module-design-overlay.md
    │   ├── module-design.md           │   └── ...
    │   ├── hazard-analysis.md         └── do_178c/
    │   └── ...                            ├── ...
    ├── do_178c/                       └── iec_62304/
    │   ├── _domain.yml                    ├── ...
    │   └── ...
    └── iec_62304/
        ├── _domain.yml
        └── ...
```

### Key Characteristics

1. **Single `domain` field in `v-model-config.yml`** — Users set `domain: iso_26262` (or `do_178c`, `iec_62304`, or leave empty/omit for domain-agnostic). This is the single point of configuration that controls all domain behavior across every command and template.

2. **Additive composition** — When a domain is configured, the overlay content is APPENDED after the base command/template content. The base never changes based on domain selection. This ensures that non-regulated teams get the exact same clean experience regardless of what overlay files exist in the repository.

3. **Graceful fallback** — If no domain is configured, or if an overlay file doesn't exist for a particular command, the base content is used as-is. No errors, no warnings — just the clean base experience.

4. **`_domain.yml` manifests** — Each domain overlay directory contains a manifest file that declares the domain's metadata: display name, governing standards, classification system (ASIL/DAL/Safety Class), and which commands have overlay content. This enables tooling to validate overlay completeness and display domain information.

5. **Standardized domain loading step** — Every command that can be enriched by overlays gains a single, reusable instruction block (replacing the current ad-hoc conditional patterns). The instruction reads: "Load v-model-config.yml. If `domain` is set and an overlay exists at `commands/overlays/{domain}/{command-name}.md`, append its content after the base instructions."

6. **Preference-based indirection** — The overlay content uses language like "prefer the domain's severity scale over the general-purpose scale" or "use the domain's coding standard checklist." This avoids duplicating base content in overlays and keeps overlays focused on what's domain-specific.

7. **Domain IDs use snake_case** — `iso_26262`, `do_178c`, `iec_62304`. Consistent, filesystem-safe, and already used in the existing conditional checks.

8. **Base commands become genuinely clean** — All safety standard references, ASIL/DAL tables, MC/DC techniques, SIL/HIL terminology, MISRA/CERT-C rules, and "regulatory-grade" language are extracted from base commands and moved to the appropriate overlay files. The base commands reference only domain-agnostic standards (IEEE 1016, ISO 29119, IEEE 42010, INCOSE, etc.).

### Refactoring Scope by Command

Based on the verified audit, each command requires the following work:

| Command | Work Required |
|---------|--------------|
| `requirements.md` | None — already clean |
| `acceptance.md` | None — already clean |
| `impact-analysis.md` | None — already clean |
| `test-results.md` | None — already clean |
| `audit-report.md` | Minor — add domain-agnostic example alongside existing regulatory example |
| `system-design.md` | Extract Freedom from Interference + Restricted Complexity sections → overlay; generalize section outline |
| `system-test.md` | Extract MC/DC, WCET, ASIL/DAL mapping → overlay; remove unconditional safety technique mentions |
| `architecture-design.md` | Extract ASIL Decomposition + Defensive Programming + Temporal Constraints → overlay; generalize isolation section |
| `integration-test.md` | Extract SIL/HIL Compatibility + Resource Contention → overlay; generalize section headers |
| `module-design.md` | Remove DO-178C/ISO 26262 from description; extract MISRA/CERT-C + Memory Management + Single Entry/Exit → overlay |
| `unit-test.md` | Move MC/DC + Variable-Level Fault Injection to overlay; conditionalize hardware interface section |
| `trace.md` | Remove "regulatory-grade" language; remove unconditional regulatory references section; create overlay with domain-specific compliance framing |
| `hazard-analysis.md` | Extract ISO 14971/ISO 26262 from description; move domain-specific severity scales to overlays; add domain-agnostic framing as default |
| `peer-review.md` | Parameterize Governing Standard mapping table; move safety standard section headers to overlays |

### Template Alignment

Templates already use a clean HTML-comment gating pattern (`<!-- SAFETY-CRITICAL SECTION -->`). The overlay architecture complements this by:

- Moving the gated content from inline comments into overlay template files
- The base template no longer contains commented-out safety sections — it is genuinely clean
- Overlay templates provide the additional sections that get appended when a domain is active
- The existing gating pattern serves as a clear migration guide: every `<!-- SAFETY-CRITICAL SECTION -->` block maps to an overlay file

### Extension.yml Updates

The 9 command descriptions that currently reference safety standards unconditionally will be updated to use domain-agnostic language. The `safety-critical` tag remains (it describes the extension's capability, not a hardcoded requirement). Domain-specific description variants can be added in a future enhancement.

### Config-Template.yml Updates

Add the `domain` field with documentation:

```yaml
# Domain configuration (optional)
# Set to activate domain-specific safety/regulatory enrichment.
# Supported values: iso_26262, do_178c, iec_62304
# Leave empty or omit for domain-agnostic V-Model workflow.
# domain: iso_26262
```

### What This Feature Does NOT Include

1. **Command logic changes** — This feature restructures content (instructions, prompts, templates), not runtime behavior. There are no script changes, no new validation logic, no new CLI flags.

2. **New commands** — No commands are added or removed. The 14 existing commands remain. `hazard-analysis` remains available even without a domain configured (it uses a general-purpose FMEA framing by default).

3. **ID lifecycle model** — Deprecation, supersession, and suspect states for spec IDs are covered by Feature 006b, not this feature.

4. **Bridge commands** — The `v-model.plan`, `v-model.tasks`, and `v-model.implement` commands are M1 (v0.7.0) scope.

5. **New domain overlays beyond the initial three** — Only `iso_26262`, `do_178c`, and `iec_62304` overlays are created. Additional domains (e.g., `iec_61508`, `fda_21cfr`) can be added later following the established pattern.

6. **Automated overlay selection** — The user must manually set `domain` in `v-model-config.yml`. There is no auto-detection of domain from project content or repository metadata.

7. **Multi-domain support** — A project can only have one active domain at a time. Multi-domain scenarios (e.g., a medical device with automotive subsystem) are out of scope for this feature.
