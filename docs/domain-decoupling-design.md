# Domain Decoupling Design — Overlay Architecture

> **Version**: 1.0 — Design Document  
> **Status**: Proposed  
> **Scope**: Decouple all safety/domain-specific instructions from base V-Cycle commands  

---

## Table of Contents

1. [Problem Statement](#1-problem-statement)
2. [Design Principles](#2-design-principles)
3. [The Overlay Architecture](#3-the-overlay-architecture)
4. [The Assembly Protocol](#4-the-assembly-protocol)
5. [Overlay File Structure](#5-overlay-file-structure)
6. [Per-File Refactoring Plan](#6-per-file-refactoring-plan)
7. [Template Migration Strategy](#7-template-migration-strategy)
8. [Content Migration Map](#8-content-migration-map)
9. [Benefits Analysis](#9-benefits-analysis)
10. [Red Team Findings & Refinements](#10-red-team-findings--refinements)
11. [Future Extensions](#11-future-extensions)
12. [Migration Checklist](#12-migration-checklist)
13. [Summary](#13-summary)

---

## 1. Problem Statement

The spec-kit V-Model extension currently embeds domain-specific safety standards (ISO 26262, DO-178C, IEC 62304, ISO 14971, etc.) directly into command instructions and templates. This creates three concrete problems:

| # | Problem | Impact |
|---|---------|--------|
| 1 | **Framing leaks** — command descriptions and goals hardcode safety language even for non-safety projects | A developer building a generic IoT device sees "regulatory-grade" and "DO-178C/ISO 26262-compliant" in every artifact |
| 2 | **Reference material bloat** — ALL domain-specific severity tables, classification scales, and regulatory references are shipped to the AI regardless of configuration | The AI processes ~100+ extra lines of irrelevant content, increasing noise and token cost |
| 3 | **Cross-domain contamination** — safety content is a MIX of ISO 26262 + DO-178C references, applied to ALL domains indiscriminately | An IEC 62304 medical device project gets ISO 26262 ASIL Decomposition and DO-178C Temporal Constraints — neither applies |

### 1.1 Current State Audit

#### Commands with Broken or Leaked Safety Content

| File | Status | Issue |
|------|--------|-------|
| `trace.md` | ❌ **HARDCODED** | No domain check anywhere. Description, goal, and Regulatory References section unconditionally cite 5 safety standards (DO-178C, ISO 26262, IEC 62304, FDA 21 CFR 820, IEC 61508) |
| `hazard-analysis.md` | ⚠️ **MIXED** | Description/goal hardcode "ISO 14971/ISO 26262-compliant". ALL domain severity tables (ISO 26262 ASIL + DO-178C DAL) shown regardless of which domain is configured |
| `module-design.md` | ⚠️ **MIXED** | Description/goal hardcode "DO-178C/ISO 26262-compliant". Conditional sections work but framing leaks |
| `peer-review.md` | ⚠️ **MIXED** | Governing standards table hardcodes safety standards for module-design and hazard-analysis. No domain check exists |
| `audit-report.md` | ⚠️ **Minor** | Safety standards appear in example commands only |

#### Commands with Cross-Domain Contamination (Previously Classified "Clean")

These commands have working conditional guards (`if domain set, enable safety sections`), but the **content within those sections mixes ISO 26262 and DO-178C references indiscriminately**:

| Command | Safety Section | ISO 26262 Content | DO-178C Content | IEC 62304 Content |
|---------|---------------|-------------------|-----------------|-------------------|
| `system-design.md` | FFI (§7.4.8), Restricted Complexity (§7.4.9) | **100% ISO 26262** | ❌ None | ❌ None |
| `architecture-design.md` | ASIL Decomposition | ISO 26262-9 §5 only | ❌ | ❌ |
| `architecture-design.md` | Defensive Programming | ISO 26262-6 §7.4.2 | DO-178C §6.3.3 | ❌ |
| `architecture-design.md` | Temporal Constraints | ❌ | **100% DO-178C §6.3.4** | ❌ |
| `system-test.md` | Structural Coverage | ISO 26262-6 §9.4.5 | DO-178C §6.4.4.2 | ❌ |
| `system-test.md` | Resource Usage Testing | ISO 26262-6 §9.4.4 | DO-178C §6.3.4 | ❌ |
| `integration-test.md` | SIL/HIL Compatibility | ISO 26262-8 §9 | DO-178C §6.4 | ❌ |
| `integration-test.md` | Resource Contention | ISO 26262-6 §7.4.11 | DO-178C §6.3.3 | ❌ |
| `module-design.md` | Complexity Constraints | ❌ | ❌ | ❌ (MISRA/CERT-C) |
| `module-design.md` | Memory Management | ISO 26262 mentioned | DO-178C mentioned | ❌ |
| `module-design.md` | Single Entry/Exit | ❌ | **100% DO-178C Level A** | ❌ |
| `unit-test.md` | MC/DC Coverage | ❌ | Implicit (DO-178C Level A req.) | ❌ |
| `unit-test.md` | Fault Injection | Generic | Generic | ❌ |

**Key Insight**: When `domain: iec_62304` is configured, the agent receives ISO 26262 ASIL Decomposition tables and DO-178C Temporal Constraint analysis — **neither of which is part of IEC 62304**. The "clean conditional" pattern only controls whether safety sections appear, not which domain's content appears.

#### Truly Clean Commands (No Safety Content)

| File | Status |
|------|--------|
| `requirements.md` | ✅ Domain-agnostic (IEEE 29148, INCOSE) |
| `acceptance.md` | ✅ Domain-agnostic (ISO 29119) |
| `impact-analysis.md` | ✅ Domain-agnostic |
| `test-results.md` | ✅ Domain-agnostic (deterministic) |

#### Extension Metadata

| File | Issue |
|------|-------|
| `extension.yml` | 3 command descriptions reference safety standards (module-design, hazard-analysis, trace) |
| `config-template.yml` | No `domain` field — commands reference it but the template doesn't define it |

---

## 2. Design Principles

| Principle | Description |
|-----------|-------------|
| **Separation of Concerns** | Base commands contain ONLY best-practice standards (IEEE, ISO, INCOSE). Domain-specific content lives in dedicated overlay files |
| **Zero Cross-Contamination** | Each domain has its own overlay directory. Only the configured domain's overlays are loaded — never content from other domains |
| **Additive Composition** | Overlays ADD sections after the base workflow. They enhance, they don't replace core instructions |
| **Preference-Based Indirection** | When a base section has a domain-variant (e.g., severity scale), the base provides a default and defers to the overlay if present. No fragile "Replace" directives |
| **Single Source of Truth** | One `domain` field in `v-model-config.yml` drives all domain behavior |
| **Progressive Enhancement** | The base V-Cycle is complete and useful without any domain. Domains enhance quality, they don't enable functionality |
| **Extensibility** | New domain = new overlay directory. No modifications to existing commands, templates, or base logic |

---

## 3. The Overlay Architecture

### 3.1 High-Level Flow

```
┌───────────────────────────────────────────────────────────────────────┐
│                          Agent Execution                              │
├───────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────────────────┐                                      │
│  │ 1. Load Base Command        │   commands/{command}.md              │
│  │    (best-practice only)     │   IEEE 1016 · ISO 29119 · INCOSE    │
│  └──────────────┬──────────────┘                                      │
│                 │                                                      │
│  ┌──────────────▼──────────────┐                                      │
│  │ 2. Read v-model-config.yml  │   domain: "iso_26262" (or empty)    │
│  └──────────────┬──────────────┘                                      │
│                 │                                                      │
│          ┌──────┴──────┐                                              │
│          │ domain set? │                                              │
│     YES  │             │  NO                                          │
│  ┌───────▼───────┐  ┌──▼──────────────┐                              │
│  │ 3. Load       │  │ 3. Skip overlay │                              │
│  │ Command       │  │ Use base only   │                              │
│  │ Overlay       │  └─────────────────┘                              │
│  │ commands/     │                                                    │
│  │ overlays/     │                                                    │
│  │ {domain}/     │                                                    │
│  │ {cmd}.md      │                                                    │
│  └───────┬───────┘                                                    │
│          │                                                            │
│  ┌───────▼─────────────────────────────────────┐                      │
│  │ 4. Execute Base Workflow                     │                      │
│  │    (generic best-practice sections)          │                      │
│  │    Where base has domain-variant sections,   │                      │
│  │    prefer overlay content if loaded          │                      │
│  └───────┬─────────────────────────────────────┘                      │
│          │                                                            │
│  ┌───────▼─────────────────────────────────────┐                      │
│  │ 5. Append Overlay Sections                   │                      │
│  │    (domain-specific additions after base)    │                      │
│  │    FFI, ASIL tables, MC/DC, regulatory refs  │                      │
│  └───────┬─────────────────────────────────────┘                      │
│          │                                                            │
│  ┌───────▼─────────────────────────────────────┐                      │
│  │ 6. Write Output                              │                      │
│  │    Base template + template overlay          │                      │
│  │    (if domain overlay template exists)       │                      │
│  └─────────────────────────────────────────────┘                      │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```

### 3.2 Directory Structure

```
spec-kit-v-model/
│
├── commands/
│   │
│   │   # ── Base Commands (best-practice only, domain-agnostic) ──
│   ├── requirements.md              # IEEE 29148, INCOSE
│   ├── acceptance.md                # ISO 29119
│   ├── system-design.md             # IEEE 1016
│   ├── system-test.md               # ISO 29119
│   ├── architecture-design.md       # IEEE 42010, Kruchten 4+1
│   ├── integration-test.md          # ISO 29119-4
│   ├── module-design.md             # Generic low-level design
│   ├── unit-test.md                 # ISO 29119-4
│   ├── hazard-analysis.md           # Generic FMEA
│   ├── peer-review.md               # Generic governing standards
│   ├── trace.md                     # Generic bidirectional traceability
│   ├── impact-analysis.md           # Already clean
│   ├── test-results.md              # Already clean
│   ├── audit-report.md              # Already clean
│   │
│   │   # ── Domain Overlays (loaded ONLY when domain is configured) ──
│   └── overlays/
│       │
│       ├── iso_26262/                      # ── Automotive Safety ──
│       │   ├── _domain.yml                 # Domain metadata & manifest
│       │   ├── system-design.md            # FFI (§7.4.8), Restricted Complexity (§7.4.9)
│       │   ├── system-test.md              # MC/DC (§9.4.5), Resource Usage (§9.4.4)
│       │   ├── architecture-design.md      # ASIL Decomposition (§5), Defensive Prog (§7.4.2)
│       │   ├── integration-test.md         # SIL/HIL (§9), Resource Contention (§7.4.11)
│       │   ├── module-design.md            # MISRA C/C++, Memory Mgmt, Restricted Complexity
│       │   ├── unit-test.md                # MC/DC Coverage, Fault Injection
│       │   ├── hazard-analysis.md          # ASIL severity scale (A-D + QM)
│       │   ├── trace.md                    # ISO 26262-6 §9 regulatory references
│       │   └── peer-review.md              # ISO 26262 governing standard overrides
│       │
│       ├── do_178c/                        # ── Aviation Safety ──
│       │   ├── _domain.yml
│       │   ├── system-design.md            # Partitioning (§6.3.3c), Resource Limits
│       │   ├── system-test.md              # Structural Coverage (§6.4.4.2), WCET
│       │   ├── architecture-design.md      # Defensive Prog (§6.3.3), Temporal (§6.3.4)
│       │   ├── integration-test.md         # Hardware/Software Integration (§6.4)
│       │   ├── module-design.md            # Single Entry/Exit (Level A), Stack Analysis
│       │   ├── unit-test.md                # MC/DC (§6.4.4.2b), Statement Coverage
│       │   ├── hazard-analysis.md          # DAL severity scale (A-E)
│       │   ├── trace.md                    # DO-178C §6.3.4 regulatory references
│       │   └── peer-review.md              # DO-178C governing standard overrides
│       │
│       └── iec_62304/                      # ── Medical Device Safety ──
│           ├── _domain.yml
│           ├── hazard-analysis.md          # Safety classification (Class A, B, C)
│           ├── trace.md                    # IEC 62304 §5.7 + FDA 21 CFR 820 references
│           ├── peer-review.md              # IEC 62304 governing standard overrides
│           └── module-design.md            # IEC 62304 §5.5 software unit design
│
├── templates/
│   │
│   │   # ── Base Templates (domain-agnostic output structure) ──
│   ├── requirements-template.md
│   ├── acceptance-plan-template.md
│   ├── system-design-template.md           # No FFI tables
│   ├── system-test-template.md             # No MC/DC sections
│   ├── architecture-design-template.md     # No ASIL decomposition
│   ├── integration-test-template.md        # No SIL/HIL sections
│   ├── module-design-template.md           # No MISRA/complexity sections
│   ├── unit-test-template.md               # No MC/DC sections
│   ├── hazard-analysis-template.md         # General-purpose severity only
│   ├── peer-review-template.md
│   ├── traceability-matrix-template.md
│   ├── audit-report-template.md
│   │
│   │   # ── Template Overlays (domain-specific output sections) ──
│   └── overlays/
│       ├── iso_26262/
│       │   ├── system-design-template.md   # FFI + Restricted Complexity output tables
│       │   ├── system-test-template.md     # MC/DC + Resource Usage output sections
│       │   ├── architecture-design-template.md  # ASIL Decomposition output tables
│       │   ├── integration-test-template.md     # SIL/HIL output sections
│       │   ├── module-design-template.md        # MISRA + Memory + Complexity output
│       │   ├── unit-test-template.md            # MC/DC + Fault Injection output
│       │   └── hazard-analysis-template.md      # ASIL classification output table
│       │
│       ├── do_178c/
│       │   ├── system-design-template.md
│       │   ├── system-test-template.md
│       │   ├── architecture-design-template.md
│       │   ├── integration-test-template.md
│       │   ├── module-design-template.md
│       │   ├── unit-test-template.md
│       │   └── hazard-analysis-template.md
│       │
│       └── iec_62304/
│           ├── hazard-analysis-template.md
│           └── module-design-template.md
│
└── config-template.yml                     # Updated with `domain` field
```

### 3.3 Domain Metadata File (`_domain.yml`)

Each overlay directory contains a `_domain.yml` manifest:

```yaml
# commands/overlays/iso_26262/_domain.yml
domain_id: iso_26262
name: "ISO 26262 — Road Vehicles Functional Safety"
version: "2018 (2nd edition)"
industry: "Automotive"
description: >
  Adds automotive functional safety requirements including ASIL classification,
  Freedom from Interference analysis, restricted complexity metrics, MC/DC 
  structural coverage, and MISRA C/C++ coding constraints.

extends:
  - system-design
  - system-test
  - architecture-design
  - integration-test
  - module-design
  - unit-test
  - hazard-analysis
  - trace
  - peer-review

standards:
  - id: "ISO 26262"
    parts:
      - "Part 3 (Concept Phase)"
      - "Part 4 (Product Dev: System Level)"
      - "Part 6 (Product Dev: Software Level)"
      - "Part 8 (Supporting Processes)"
      - "Part 9 (ASIL-Oriented and Safety-Oriented Analysis)"
  - id: "MISRA C:2012 / MISRA C++:2023"
    scope: "Coding standard for module design"
```

```yaml
# commands/overlays/iec_62304/_domain.yml
domain_id: iec_62304
name: "IEC 62304 — Medical Device Software Lifecycle"
version: "2015 (Amendment 1)"
industry: "Medical Devices"
description: >
  Adds medical device software safety classification (Class A, B, C),
  ISO 14971 risk management integration, and FDA 21 CFR 820 traceability.

extends:
  - hazard-analysis
  - trace
  - peer-review
  - module-design

standards:
  - id: "IEC 62304:2006+AMD1:2015"
    clauses:
      - "§5.5 Software Unit Implementation and Verification"
      - "§5.7 Software Integration and Integration Testing"
  - id: "ISO 14971:2019"
    scope: "Risk management integration for hazard analysis"
  - id: "FDA 21 CFR Part 820"
    scope: "Design control traceability requirements"
```

---

## 4. The Assembly Protocol

### 4.1 Standardized Domain Loading Step

Every command that supports domain overlays includes this **exact standardized step**, replacing all current ad-hoc conditional patterns:

```markdown
### N. Domain Configuration

Load `v-model-config.yml` (if it exists at the repository root).

**If `domain` is set** (e.g., `iso_26262`, `do_178c`, `iec_62304`):
1. Read the command overlay: `commands/overlays/{domain}/{this-command-filename}`
   - If it exists: note its additional sections and preferences
   - If it does not exist: this domain does not extend this command — proceed with base only
2. Read the template overlay: `templates/overlays/{domain}/{this-template-filename}`
   - If it exists: its output sections will be appended after the base template's output
   - If it does not exist: use the base template only
3. Where the base command has a domain-variant section (marked with
   "If a domain overlay is loaded, prefer its content"), use the overlay's
   version instead of the base default

**If `domain` is empty or absent:**
- Proceed with the base command only
- Do NOT include any safety-critical or domain-specific sections
- Use generic best-practice terminology throughout
```

### 4.2 Preference-Based Indirection (No "Replace" Directives)

When a base section has a domain-variant (e.g., severity scales in hazard-analysis), the base uses **preference-based indirection** rather than requiring the overlay to "replace" content:

**In the base command (hazard-analysis.md):**
```markdown
#### 3.5 Severity Classification

**If a domain overlay is loaded**, use the severity scale defined in the overlay.
Otherwise, use the general-purpose scale below:

| Severity | Definition |
|----------|-----------|
| Catastrophic | Death or permanent injury; complete system destruction |
| Critical | Severe injury or major system damage |
| Serious | Moderate injury or significant degradation |
| Minor | Slight injury or minor degradation |
| Negligible | No injury; cosmetic or inconvenience-level impact |
```

**In the ISO 26262 overlay (overlays/iso_26262/hazard-analysis.md):**
```markdown
## Preferred Severity Scale

Use this ASIL classification instead of the base general-purpose scale:

| Severity | ASIL Rating | Definition |
|----------|-------------|-----------|
| S3 | ASIL D | Life-threatening (survival uncertain) |
| S3 | ASIL C | Life-threatening (survival probable) |
| S2 | ASIL B | Severe injuries |
| S1 | ASIL A | Light injuries |
| S0 | QM | No injuries |

Use "ASIL Level" terminology throughout the hazard register.
```

**Why this is better than "Replace":**
- The base command is self-contained and always works without overlays
- The AI doesn't need to suppress or undo anything it already read
- The preference instruction is a simple "if present, prefer this" — natural for AI agents
- Graceful degradation: if the overlay file is missing, the default scale is used

### 4.3 How Commands Use Overlays — End-to-End Examples

#### Example A: `system-design.md` (Base) + `iso_26262/system-design.md` (Overlay)

**Base command produces** (4 views, generic):
1. Decomposition View (IEEE 1016 §5.1)
2. Dependency View (IEEE 1016 §5.2)
3. Interface View (IEEE 1016 §5.3)
4. Data Design View (IEEE 1016 §5.4)

**ISO 26262 overlay adds** (2 domain sections):
5. Freedom from Interference — ISO 26262-6 §7.4.8
6. Restricted Complexity — ISO 26262-6 §7.4.9

**DO-178C overlay would add** (different sections):
5. Software Partitioning — DO-178C §6.3.3c
6. Resource Limitation Analysis — DO-178C §6.3.4

**IEC 62304 overlay**: Does NOT exist for system-design → base only.

The AI sees base → loads overlay → appends sections 5-6 to the output.

#### Example B: `hazard-analysis.md` (Base) + `do_178c/hazard-analysis.md` (Overlay)

**Base command provides**:
- Generic FMEA methodology
- General-purpose severity scale (default, via preference indirection)

**DO-178C overlay provides**:
- DAL failure condition classification (preferred over default scale)
- DAL-specific risk matrix guidance

The AI reads the base → finds "prefer overlay scale if present" → uses DAL scale.

**No ISO 26262 content visible. No IEC 62304 content visible. Zero contamination.**

#### Example C: `unit-test.md` (Base) + `iec_62304/unit-test.md` (No Overlay)

**Base command provides**:
- ISO 29119-4 white-box unit test techniques
- Statement Coverage, Branch Coverage, BVA, Error Guessing, EP

**IEC 62304 overlay**: Does NOT exist for unit-test.

**Result**: Pure ISO 29119-4 unit testing. No MC/DC, no fault injection, no safety overhead.
IEC 62304 §5.5.5 only requires verification appropriate to the software safety class — for Class A, unit testing may be documented but isn't mandated at MC/DC level.

---

## 5. Overlay File Structure

### 5.1 Command Overlay Format

```markdown
# Domain Overlay: {Domain Standard Name}
# Applies to: {base-command-filename}
# Standard: {Standard ID and relevant clauses}

## Preferred Content

### Preferred: {Section Name}
{Content that the base command should prefer over its default when this overlay is loaded}

## Additional Sections

### {Section Title} ({Standard Clause Reference})

{Instructions for generating this additional section}

| Column 1 | Column 2 | ... |
|----------|----------|-----|

Rules:
- {Rule 1}
- {Rule 2}

## Additional Review Criteria (peer-review overlays only)

### {Artifact Type} — {Domain} Extensions
{Extra criteria to apply when reviewing this artifact type under this domain}
```

### 5.2 Template Overlay Format

```markdown
<!-- Domain overlay: {domain_id} — Append after base template sections -->

## {Domain-Specific Section Title}

| Column 1 | Column 2 | ... |
|----------|----------|-----|
| {placeholder} | {placeholder} | ... |
```

---

## 6. Per-File Refactoring Plan

### 6.1 `trace.md` — HARDCODED → Domain-Aware

**Problem**: No domain check. Lines 2, 26-28, 285-290 hardcode "regulatory-grade" + 5 safety standards.

**Base refactoring**:

| Location | Current | Proposed |
|----------|---------|----------|
| Line 2 (description) | "Build a regulatory-grade Bidirectional Traceability Matrix..." | "Build a Bidirectional Traceability Matrix with five-matrix output and coverage audit" |
| Lines 26-28 (goal) | "Build a **regulatory-grade** RTM... Industry standards — **DO-178C**, **ISO 26262**, **IEC 62304**, **FDA 21 CFR Part 820**, **IEC 61508** — explicitly dictate what a compliant traceability artifact must contain." | "Build a **Bidirectional Requirements Traceability Matrix (RTM)** that provides a complete, auditable trail between every requirement, its test cases, and its executable scenarios. This document ensures every requirement is tested and every test traces back to a requirement." |
| Lines 32-51 (4 Pillars) | "Every RTM generated... MUST satisfy these 4 pillars" — currently phrased with regulatory language | Keep the 4 Pillars (bidirectionality, complete coverage, gap analysis, independence) — they are sound engineering practice regardless of domain. Remove regulatory framing. |
| Lines 285-290 (Regulatory References) | Unconditional section citing 5 standards | Remove entirely from base. Move to domain overlays. |

**New overlays**:
- `overlays/iso_26262/trace.md` — ISO 26262-6 §9 traceability references + "regulatory-grade" framing
- `overlays/do_178c/trace.md` — DO-178C §6.3.4 traceability references + certification framing
- `overlays/iec_62304/trace.md` — IEC 62304 §5.7 + FDA 21 CFR 820 §820.30(i) references

**Add**: Standardized domain loading step in Execution Steps.

### 6.2 `hazard-analysis.md` — MIXED → Clean + Overlay

**Problem**: Description/goal hardcode "ISO 14971/ISO 26262-compliant". All 3 domain severity tables shown regardless of domain.

**Base refactoring**:

| Location | Current | Proposed |
|----------|---------|----------|
| Line 2 (description) | "Generate an ISO 14971/ISO 26262-compliant Hazard Analysis (FMEA)..." | "Generate a Hazard Analysis (FMEA) with operational state awareness, traceable HAZ-NNN IDs, and progressive deepening" |
| Line 26 (goal) | "Generate an **ISO 14971 / ISO 26262-compliant Hazard Analysis**..." | "Generate a **Hazard Analysis** (Failure Mode and Effects Analysis — FMEA) where **every system component** (`SYS-NNN`)..." |
| Lines 73-77 (domain check) | Per-domain severity switch (iso_26262 → ASIL, do_178c → DAL, iec_62304 → Class, empty → general) | Replace with: "If domain overlay is loaded, use the overlay's severity scale. Otherwise, use general-purpose scale." |
| Lines 135-143 (general-purpose table) | Keep | Keep — this IS the base default |
| Lines 145-153 (ISO 26262 ASIL table) | Remove from base | Move to `overlays/iso_26262/hazard-analysis.md` |
| Lines 155-163 (DO-178C DAL table) | Remove from base | Move to `overlays/do_178c/hazard-analysis.md` |
| IEC 62304 Class A/B/C table | Currently missing (bug!) — only mentioned in line 76 | Create in `overlays/iec_62304/hazard-analysis.md` |

**Note**: The IEC 62304 safety classification table (Class A, B, C) is referenced in the domain check logic (line 76) but **never actually defined** in the file — this is a gap the overlay will fix.

### 6.3 `module-design.md` — MIXED → Clean + Overlay

**Problem**: Description/goal hardcode "DO-178C/ISO 26262-compliant". Safety sections mix MISRA, DO-178C, and ISO 26262.

**Base refactoring**:

| Location | Current | Proposed |
|----------|---------|----------|
| Line 2 (description) | "Decompose architecture modules into DO-178C/ISO 26262-compliant low-level module designs..." | "Decompose architecture modules into low-level module designs with four mandatory views and ARCH↔MOD traceability" |
| Line 26 (goal) | "...DO-178C/ISO 26262-compliant Module Design..." | "...a Module Design where **every architecture module** (`ARCH-NNN`) maps to at least one low-level module specification (`MOD-NNN`)..." |
| Lines 153-177 (Safety-Critical Sections) | 3 subsections: Complexity (MISRA), Memory (DO-178C/ISO 26262), Single Entry/Exit (DO-178C Level A) | Remove entirely from base. Distribute to domain overlays. |

**New overlays**:
- `overlays/iso_26262/module-design.md` — MISRA C/C++, memory management, restricted complexity per ISO 26262-6 §7
- `overlays/do_178c/module-design.md` — Single entry/exit (Level A), stack analysis, memory mgmt per DO-178C §6.3
- `overlays/iec_62304/module-design.md` — IEC 62304 §5.5 unit-level verification requirements

### 6.4 `peer-review.md` — MIXED → Domain-Aware Governing Standards

**Problem**: Governing standard table hardcodes safety standards. Section headers hardcode safety standards. No domain check.

**Base refactoring**:

| Location | Current | Proposed |
|----------|---------|----------|
| Line 74 | `module-design.md \| MOD \| DO-178C / ISO 26262` | `module-design.md \| MOD \| Low-Level Design Best Practices` |
| Line 76 | `hazard-analysis.md \| HAZ \| ISO 14971 / ISO 26262` | `hazard-analysis.md \| HAZ \| FMEA Best Practices` |
| Line 141 | `#### 4.6 Module Design — DO-178C / ISO 26262` | `#### 4.6 Module Design — Low-Level Design` |
| Line 157 | `#### 4.8 Hazard Analysis — ISO 14971 / ISO 26262` | `#### 4.8 Hazard Analysis — FMEA` |

**Add**: Standardized domain loading step. Add note: "If a domain overlay is loaded for peer-review, it provides domain-specific governing standards and additional review criteria."

**New overlays** provide governing standard overrides:
- `overlays/iso_26262/peer-review.md` — `module-design.md → ISO 26262-6 §7`, `hazard-analysis.md → ISO 26262-3 §7 (HARA)`, plus ASIL consistency checks
- `overlays/do_178c/peer-review.md` — `module-design.md → DO-178C §6.3`, `hazard-analysis.md → DO-178C §2.3 (FHA)`, plus DAL consistency checks
- `overlays/iec_62304/peer-review.md` — `hazard-analysis.md → ISO 14971 + IEC 62304 §5.7`, plus safety class consistency checks

### 6.5 `system-design.md` — Clean Conditional → Overlay

**Problem**: Conditional pattern works, but safety content is 100% ISO 26262-specific (FFI §7.4.8, Restricted Complexity §7.4.9). DO-178C and IEC 62304 projects get inappropriate content.

**Base refactoring**:
- Remove lines 141-156 (Safety-Critical Sections)
- Remove domain check from line 54
- Replace with standardized domain loading step
- Remove line 182 from Write Output list ("Safety-Critical Sections: FFI and Restricted Complexity (if domain configured)")

**New overlays**:
- `overlays/iso_26262/system-design.md` — FFI (§7.4.8), Restricted Complexity (§7.4.9)
- `overlays/do_178c/system-design.md` — Software Partitioning (§6.3.3c), Resource Limitation
- IEC 62304: No overlay needed (IEC 62304 doesn't have system-design-level safety requirements)

### 6.6 `architecture-design.md` — Clean Conditional → Overlay

**Problem**: Safety sections mix ISO 26262 (ASIL Decomposition) with DO-178C (Temporal Constraints). The two domains have different safety requirements at this layer.

**Base refactoring**:
- Remove lines 171-197 (Safety-Critical Sections: ASIL Decomposition, Defensive Programming, Temporal Constraints)
- Replace domain check with standardized domain loading step

**New overlays**:
- `overlays/iso_26262/architecture-design.md` — ASIL Decomposition (§5), Defensive Programming (§7.4.2)
- `overlays/do_178c/architecture-design.md` — Defensive Programming (§6.3.3), Temporal & Execution Constraints (§6.3.4)

### 6.7 `system-test.md` — Clean Conditional → Overlay

**Problem**: Safety sections cite both DO-178C §6.4.4.2 and ISO 26262-6 §9.4.5 simultaneously.

**Base refactoring**:
- Remove lines 172-191 (Safety-Critical Test Sections)
- Replace domain check with standardized domain loading step

**New overlays**:
- `overlays/iso_26262/system-test.md` — Structural Coverage (§9.4.5), Resource Usage (§9.4.4)
- `overlays/do_178c/system-test.md` — Structural Coverage (§6.4.4.2), WCET Analysis

### 6.8 `integration-test.md` — Clean Conditional → Overlay

**Problem**: Safety sections cite both ISO 26262-8 §9 and DO-178C §6.4 simultaneously.

**Base refactoring**:
- Remove lines 181-199 (Safety-Critical Test Sections)
- Replace domain check with standardized domain loading step

**New overlays**:
- `overlays/iso_26262/integration-test.md` — SIL/HIL (§9), Resource Contention (§7.4.11)
- `overlays/do_178c/integration-test.md` — Hardware/Software Integration (§6.4)

### 6.9 `unit-test.md` — Clean Conditional → Overlay

**Problem**: MC/DC is a DO-178C Level A requirement. Variable-level fault injection is generic. Both are applied to all domains.

**Base refactoring**:
- Remove lines 210-237 (Safety-Critical Techniques)
- Replace domain check with standardized domain loading step

**New overlays**:
- `overlays/iso_26262/unit-test.md` — MC/DC (for ASIL D), Fault Injection
- `overlays/do_178c/unit-test.md` — MC/DC (§6.4.4.2b for Level A), Statement Coverage requirements

### 6.10 `audit-report.md` — Minor Cleanup

**Problem**: Safety standards in example commands (lines 41, 60).

**Refactoring**: Replace safety-specific examples with generic ones.

### 6.11 `extension.yml` — Generic Descriptions

| Command | Current Description | Proposed Description |
|---------|-------------------|---------------------|
| `module-design` | "Decompose architecture modules into **DO-178C/ISO 26262-compliant** low-level module designs with four mandatory views..." | "Decompose architecture modules into low-level module designs with four mandatory views and ARCH↔MOD traceability" |
| `hazard-analysis` | "Generate an **ISO 14971/ISO 26262-compliant** Hazard Analysis (FMEA)..." | "Generate a Hazard Analysis (FMEA) with operational state awareness, traceable HAZ-NNN IDs, and progressive deepening" |
| `trace` | "Build a **regulatory-grade** Traceability Matrix (Matrix A + B + C + D + H: REQ → ATP → ..." | "Build a Bidirectional Traceability Matrix (Matrix A + B + C + D + H) with coverage audit and gap detection" |

### 6.12 `config-template.yml` — Add Domain Field

Add at the top of the file, before `output_dir`:

```yaml
# Domain-specific safety standard (optional)
# Enables domain-specific safety sections, severity scales, and regulatory
# references in generated artifacts. When set, the extension loads overlay
# instructions from commands/overlays/{domain}/ and templates/overlays/{domain}/.
#
# Supported values:
#   iso_26262  — Automotive (ISO 26262 Road Vehicles Functional Safety)
#   do_178c    — Aviation (DO-178C Software Considerations in Airborne Systems)
#   iec_62304  — Medical Devices (IEC 62304 Medical Device Software Lifecycle)
#
# Leave empty or comment out for a generic best-practice V-Cycle with no
# domain-specific safety requirements.
# domain: ""
```

---

## 7. Template Migration Strategy

### 7.1 Current State

Templates use `<!-- SAFETY-CRITICAL SECTION: Only include when v-model-config.yml domain is set -->` HTML comment guards. The content within these guards is well-structured but, like commands, mixes ISO 26262 and DO-178C references.

### 7.2 Target State

**Base templates**: Remove ALL HTML-commented safety sections. The base template produces clean, generic output.

**Template overlays**: Each domain's overlay directory contains the additional output sections.

### 7.3 Templates Requiring Migration

| Template | Safety Content to Migrate | ISO 26262 Overlay | DO-178C Overlay | IEC 62304 Overlay |
|----------|--------------------------|-------------------|-----------------|-------------------|
| `system-design-template.md` | FFI table, Restricted Complexity table | ✅ | ✅ (adapted) | ❌ |
| `architecture-design-template.md` | ASIL Decomposition, Defensive Programming, Temporal Constraints | ✅ | ✅ (adapted) | ❌ |
| `integration-test-template.md` | SIL/HIL Compatibility, Resource Contention | ✅ | ✅ (adapted) | ❌ |
| `module-design-template.md` | Complexity Constraints, Memory Management, Single Entry/Exit | ✅ | ✅ (adapted) | ✅ (§5.5) |
| `system-test-template.md` | Structural Coverage (MC/DC), Resource Usage Testing | ✅ | ✅ (adapted) | ❌ |
| `unit-test-template.md` | MC/DC Coverage, Variable-Level Fault Injection | ✅ | ✅ (adapted) | ❌ |
| `hazard-analysis-template.md` | ASIL table, DAL table | ✅ | ✅ | ✅ (Class A/B/C) |

**Templates NOT requiring migration** (no safety content):
- `requirements-template.md`
- `acceptance-plan-template.md`
- `peer-review-template.md`
- `traceability-matrix-template.md`
- `audit-report-template.md`

---

## 8. Content Migration Map

This table traces exactly what moves from each source file to which destination:

### Commands

| Source File | Lines | Content | Destination |
|-------------|-------|---------|-------------|
| `trace.md` | 2 | "regulatory-grade" in description | Rewrite as generic description |
| `trace.md` | 26-28 | 5 safety standards in goal framing | Rewrite as generic goal |
| `trace.md` | 285-290 | Regulatory References section | Split to `overlays/{domain}/trace.md` |
| `hazard-analysis.md` | 2 | "ISO 14971/ISO 26262-compliant" in description | Rewrite as generic description |
| `hazard-analysis.md` | 26 | "ISO 14971 / ISO 26262-compliant" in goal | Rewrite as generic goal |
| `hazard-analysis.md` | 73-77 | Per-domain severity switch | Replace with preference indirection |
| `hazard-analysis.md` | 145-153 | ISO 26262 ASIL severity table | `overlays/iso_26262/hazard-analysis.md` |
| `hazard-analysis.md` | 155-163 | DO-178C DAL severity table | `overlays/do_178c/hazard-analysis.md` |
| `module-design.md` | 2 | "DO-178C/ISO 26262-compliant" in description | Rewrite as generic description |
| `module-design.md` | 26 | "DO-178C/ISO 26262-compliant" in goal | Rewrite as generic goal |
| `module-design.md` | 153-177 | 3 safety subsections (MISRA, Memory, Single Entry/Exit) | Split to `overlays/{domain}/module-design.md` |
| `peer-review.md` | 74 | "DO-178C / ISO 26262" governing standard | "Low-Level Design Best Practices" |
| `peer-review.md` | 76 | "ISO 14971 / ISO 26262" governing standard | "FMEA Best Practices" |
| `peer-review.md` | 141 | "DO-178C / ISO 26262" section header | "Low-Level Design" |
| `peer-review.md` | 157 | "ISO 14971 / ISO 26262" section header | "FMEA" |
| `system-design.md` | 54-55 | Domain check (inline) | Standardized domain loading step |
| `system-design.md` | 141-156 | FFI + Restricted Complexity (ISO 26262 only) | `overlays/iso_26262/system-design.md` |
| `architecture-design.md` | 64-65 | Domain check (inline) | Standardized domain loading step |
| `architecture-design.md` | 171-197 | ASIL Decomp + Defensive Prog + Temporal | Split to `overlays/{domain}/architecture-design.md` |
| `system-test.md` | 59-60 | Domain check (inline) | Standardized domain loading step |
| `system-test.md` | 172-191 | MC/DC + Resource Usage (mixed refs) | Split to `overlays/{domain}/system-test.md` |
| `integration-test.md` | 61-62 | Domain check (inline) | Standardized domain loading step |
| `integration-test.md` | 181-199 | SIL/HIL + Resource Contention (mixed refs) | Split to `overlays/{domain}/integration-test.md` |
| `unit-test.md` | 63-64 | Domain check (inline) | Standardized domain loading step |
| `unit-test.md` | 210-237 | MC/DC + Fault Injection | Split to `overlays/{domain}/unit-test.md` |
| `audit-report.md` | 41, 60 | Safety standards in examples | Generic examples |

### Metadata

| Source File | Content | Destination |
|-------------|---------|-------------|
| `extension.yml` line 47 | "DO-178C/ISO 26262-compliant" | Generic description |
| `extension.yml` line 55 | "ISO 14971/ISO 26262-compliant" | Generic description |
| `extension.yml` line 75 | "regulatory-grade" | Generic description |
| `config-template.yml` | (missing) | Add `domain` field with documentation |

### Templates

| Source Template | Safety Content | Destination |
|----------------|---------------|-------------|
| `system-design-template.md` | HTML-commented FFI + Complexity sections | `templates/overlays/{domain}/system-design-template.md` |
| `architecture-design-template.md` | HTML-commented ASIL + Defensive + Temporal sections | `templates/overlays/{domain}/architecture-design-template.md` |
| `integration-test-template.md` | HTML-commented SIL/HIL + Contention sections | `templates/overlays/{domain}/integration-test-template.md` |
| `module-design-template.md` | HTML-commented MISRA + Memory + Entry/Exit sections | `templates/overlays/{domain}/module-design-template.md` |
| `system-test-template.md` | HTML-commented MC/DC + Resource sections | `templates/overlays/{domain}/system-test-template.md` |
| `unit-test-template.md` | HTML-commented MC/DC + Fault Injection sections | `templates/overlays/{domain}/unit-test-template.md` |
| `hazard-analysis-template.md` | HTML-commented ASIL + DAL tables | `templates/overlays/{domain}/hazard-analysis-template.md` |

---

## 9. Benefits Analysis

### 9.1 For Non-Safety Projects (domain empty/absent)

| Aspect | Before (Current) | After (Overlay Architecture) |
|--------|-------------------|------------------------------|
| System design | AI sees "Safety-Critical Sections" header + ISO 26262 FFI content even if skipped | Clean 4-view IEEE 1016 design — zero safety mentions |
| Hazard analysis | AI sees ALL severity tables (general + ASIL + DAL) = ~30 extra lines | Only general-purpose FMEA with 5-level severity |
| Traceability | Told to build "regulatory-grade" matrix citing 5 safety standards | Builds "bidirectional traceability matrix" — no regulatory framing |
| Module design | Description says "DO-178C/ISO 26262-compliant" | Description says "low-level module designs with four mandatory views" |
| Peer review | Module-design reviewed against "DO-178C / ISO 26262" | Module-design reviewed against "Low-Level Design Best Practices" |
| AI context waste | ~100-150 extra lines of safety content per command | Zero safety content — faster, cheaper, less noisy |

### 9.2 For Safety Projects (domain configured)

| Aspect | Before (Current) | After (Overlay Architecture) |
|--------|-------------------|------------------------------|
| Cross-domain contamination | `domain: iso_26262` → AI still sees DO-178C DAL tables and DO-178C §6.3.4 references | Sees ONLY ISO 26262 content |
| IEC 62304 accuracy | Gets ISO 26262 FFI and DO-178C Temporal — neither applies | Gets only IEC 62304-specific requirements (safety classes, ISO 14971 risk management) |
| Completeness | trace.md has no domain check at all | All domain-relevant commands have proper overlay support |
| Missing content | IEC 62304 safety class table referenced but never defined | Each domain overlay provides its complete classification scale |
| Auditability | Safety requirements scattered across 14 files | Each domain's requirements isolated in `overlays/{domain}/` |

### 9.3 For Extension Maintainability

| Aspect | Before (Current) | After (Overlay Architecture) |
|--------|-------------------|------------------------------|
| Adding a new domain (e.g., EN 50128 Railway) | Edit ~10 command files + ~7 templates to add new conditional branches | Create `overlays/en_50128/` with domain-specific overlay files |
| Updating a domain | Find safety content scattered across 10+ files | All content in one directory — `overlays/{domain}/` |
| Removing a domain | Surgically remove conditionals from every file | Delete the overlay directory |
| Testing | Must test all 14 commands × all domains (42+ test combinations) | Test base independently; test each overlay independently |
| Domain expert review | Expert must read all 14 command files to find relevant content | Expert reads only their `overlays/{domain}/` directory |

---

## 10. Red Team Findings & Refinements

This section documents the adversarial review performed against the initial design, including weaknesses discovered and refinements applied.

### 10.1 Finding: Cross-Domain Contamination Worse Than Initially Assessed

**Severity**: CRITICAL  
**Discovery**: The initial audit classified 6 commands as "✅ CLEAN" because they had working conditional guards. Deep inspection revealed that the **content within those guards is domain-mixed** — ISO 26262 and DO-178C references appear in the same sections, applied indiscriminately to all domains.

**Impact**: An IEC 62304 medical device project configured with `domain: iec_62304` would receive:
- ISO 26262-6 §7.4.8 Freedom from Interference analysis (not in IEC 62304)
- ISO 26262-9 §5 ASIL Decomposition (ASIL is automotive, not medical)
- DO-178C §6.3.4 Temporal Constraints (aviation, not medical)

**Resolution**: This finding **strengthens** the overlay architecture. Per-domain overlays ensure each domain only injects its own applicable standards.

### 10.2 Finding: "Replace" Directives Are Fragile

**Severity**: MODERATE  
**Discovery**: The initial design proposed overlay files could "Replace" base sections. This requires the AI to suppress content it already read — cognitively complex and error-prone.

**Resolution**: Replaced with **preference-based indirection**. The base command always provides a default, and the instruction says "if overlay is loaded, prefer its content." No suppression needed. See Section 4.2.

### 10.3 Finding: File Count Triples

**Severity**: MODERATE  
**Discovery**: Moving from 26 files to ~77 files is a significant increase.

**Mitigations applied**:
1. Each overlay is small (30-80 lines vs. 200-300 line commands)
2. `_domain.yml` manifests make it easy to audit what exists
3. Not all commands need overlays for all domains (IEC 62304 needs only ~4 overlays vs. ISO 26262's ~9)
4. The total line count may decrease as conditional blocks are removed from base files

### 10.4 Finding: Assembly Adds a Failure Point

**Severity**: MODERATE  
**Discovery**: The AI must dynamically construct and read overlay file paths, adding a point where things could go wrong.

**Mitigations applied**:
1. The assembly protocol includes explicit fallback: "If the overlay file does not exist or cannot be read, proceed with the base command only"
2. The AI already reads 3-5 files per command (config, templates, existing artifacts) — one more read is well within its capability
3. The `_domain.yml` manifest documents which overlays exist, reducing guesswork

### 10.5 Finding: IEC 62304 Has Different Requirements Than ISO 26262/DO-178C

**Severity**: LOW (design already handles this)  
**Discovery**: IEC 62304 is a lifecycle process standard, not a technical safety standard like ISO 26262. It doesn't mandate FFI, ASIL decomposition, MC/DC, or restricted complexity. Its safety classes (A, B, C) determine **how much** documentation is required, not **what kind** of safety analysis to perform.

**Resolution**: The IEC 62304 overlay directory is intentionally lean (~4 files vs. ~9 for ISO 26262), reflecting the standard's different scope. This is correct behavior, not a gap.

### 10.6 Alternatives Considered and Rejected

| Alternative | Why Rejected |
|-------------|-------------|
| **Fix leaks only** (minimal changes to 4 files) | Doesn't solve cross-domain contamination in "clean" commands. IEC 62304 projects still get ISO 26262 content. |
| **Per-domain inline branching** (`if iso_26262: ... elif do_178c: ... elif iec_62304: ...`) | Commands become very long. All domain content always in AI context. Adding a new domain means editing every command file. |
| **Single domain-pack file per domain** (one large file per domain covering all commands) | Very long files. AI must load ALL domain content even for one command. Harder to maintain. |

---

## 11. Future Extensions

### 11.1 Multi-Domain Composition

Some projects must comply with multiple standards simultaneously (e.g., an automotive medical device: ISO 26262 + IEC 62304). The overlay architecture supports this naturally as a future enhancement:

```yaml
# v-model-config.yml (future)
domain:
  - iso_26262
  - iec_62304
```

The assembly protocol would load overlays from both directories and merge them. Conflict resolution rules would be needed for overlapping sections (e.g., which severity scale takes precedence — likely the more restrictive one).

### 11.2 Custom / Organization-Specific Domains

Organizations could create custom domain overlays for internal standards:

```
commands/overlays/
  custom_acme_safety/
    _domain.yml
    system-design.md
    ...
```

### 11.3 Domain Validation Command

A future `speckit.v-model.validate-domain` command could verify:
- All required overlay files exist for a configured domain
- Overlays are consistent with the domain's `_domain.yml` manifest
- No orphaned overlay files without manifest entries

### 11.4 Domain-Specific Template Variants

Beyond safety sections, domains could customize entire output formats — e.g., a DO-178C domain might add Plan for Software Aspects of Certification (PSAC) header references to every artifact.

---

## 12. Migration Checklist

### Phase 1: Infrastructure & Critical Fixes

**Goal**: Fix all broken/leaked safety content and establish the overlay directory structure.

- [ ] Add `domain` field to `config-template.yml`
- [ ] Create `commands/overlays/` directory structure (iso_26262, do_178c, iec_62304)
- [ ] Create `templates/overlays/` directory structure
- [ ] Write `_domain.yml` manifests for all 3 domains
- [ ] Fix `trace.md`: Remove hardcoded safety framing, add domain loading step
- [ ] Fix `hazard-analysis.md`: Remove safety framing, extract domain severity tables
- [ ] Fix `module-design.md`: Remove safety framing
- [ ] Fix `peer-review.md`: Genericize governing standards and section headers
- [ ] Fix `audit-report.md`: Replace safety examples
- [ ] Fix `extension.yml`: Update 3 command descriptions

### Phase 2: Extract Command Overlays

**Goal**: Migrate all inline conditional safety content to per-domain overlay files.

- [ ] `system-design.md`: Extract FFI + Restricted Complexity → iso_26262 overlay; create do_178c overlay
- [ ] `architecture-design.md`: Split ASIL Decomp → iso_26262; Temporal → do_178c
- [ ] `system-test.md`: Extract MC/DC + Resource Usage → domain-specific overlays
- [ ] `integration-test.md`: Extract SIL/HIL + Contention → domain-specific overlays
- [ ] `module-design.md`: Extract MISRA/Memory/Entry-Exit → domain-specific overlays
- [ ] `unit-test.md`: Extract MC/DC + Fault Injection → domain-specific overlays
- [ ] `hazard-analysis.md`: Create iso_26262, do_178c, iec_62304 severity overlays
- [ ] `trace.md`: Create regulatory reference overlays for all 3 domains
- [ ] `peer-review.md`: Create governing standard override overlays for all 3 domains

### Phase 3: Extract Template Overlays

**Goal**: Migrate HTML-commented safety sections from templates to overlay files.

- [ ] `system-design-template.md` → domain overlays
- [ ] `architecture-design-template.md` → domain overlays
- [ ] `integration-test-template.md` → domain overlays
- [ ] `module-design-template.md` → domain overlays
- [ ] `system-test-template.md` → domain overlays
- [ ] `unit-test-template.md` → domain overlays
- [ ] `hazard-analysis-template.md` → domain overlays

### Phase 4: Documentation & Validation

- [ ] Update `README.md` to document the domain overlay system
- [ ] Update `docs/standards-reference.md` to reflect the new architecture
- [ ] Test each command WITHOUT domain → pure best-practice output
- [ ] Test each command WITH iso_26262 → base + ISO 26262 overlay only
- [ ] Test each command WITH do_178c → base + DO-178C overlay only
- [ ] Test each command WITH iec_62304 → base + IEC 62304 overlay only
- [ ] Verify NO cross-domain contamination in any test scenario

---

## 13. Summary

The **Domain Overlay Architecture** solves all four stated requirements:

| Requirement | Solution |
|-------------|----------|
| Agents only consider domain-specific standards when domain IS configured | Overlays are loaded ONLY when `domain` is set. Base commands contain zero safety content. |
| High-quality generic domain-less V-Cycle when domain is NOT configured | Base commands use IEEE, ISO, and INCOSE best-practice standards — complete and useful without any domain. |
| No cross-domain contamination | Each domain has its own isolated overlay directory. `domain: iso_26262` loads ONLY ISO 26262 overlays — no DO-178C, no IEC 62304 content. |
| Pattern allows ADDING domain instructions to currently domain-agnostic commands | Any command can gain domain support by adding an overlay file to the domain's directory — no changes to the base command. |

### Design Decisions

| Decision | Rationale |
|----------|-----------|
| **File-based overlays** (not inline branching) | Eliminates cross-domain contamination. Each domain's content is physically isolated. |
| **Preference-based indirection** (not "Replace" directives) | Base commands are always self-contained. The AI doesn't need to suppress content. Graceful degradation if overlay is missing. |
| **Per-command overlays** (not single domain-pack files) | AI only loads content relevant to the current command. Less context, less noise, lower cost. |
| **`_domain.yml` manifests** | Self-documenting. Makes it easy to audit, validate, and discover what each domain provides. |
| **Phased migration** | Reduces risk. Phase 1 fixes critical leaks. Phase 2 completes the architecture. Phase 3 handles templates. |
