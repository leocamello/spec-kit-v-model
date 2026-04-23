---
title: Configuration Reference
description: Complete reference for the V-Model Extension Pack configuration file — v-model-config.yml options, domain settings, and safety-critical section generation.
---

# Configuration Reference

The V-Model Extension Pack uses an optional `v-model-config.yml` file to control extension behavior at the project level.

## File Location

Place the configuration file in the **repository root**:

```
your-project/
├── v-model-config.yml    ← Configuration file
├── .specify/
├── specs/
│   └── {feature}/
│       └── v-model/
│           ├── requirements.md
│           └── ...
└── ...
```

The file is Git-tracked, making configuration decisions auditable.

## Schema

```yaml
# v-model-config.yml
domain: ""  # Regulated domain identifier (optional)
```

---

## Configuration Options

### `domain`

Controls safety-critical section generation across V-Model commands.

| Attribute | Value |
|-----------|-------|
| **Type** | String (enum) |
| **Default** | `""` (empty — non-regulated) |
| **Required** | No |

**Valid values:**

| Value | Standard | Description |
|-------|----------|-------------|
| `""` (empty) | None | Non-regulated mode — no safety-critical sections |
| `iso_26262` | ISO 26262 | Automotive functional safety |
| `do_178c` | DO-178C | Aerospace software assurance |
| `iec_62304` | IEC 62304 | Medical device software lifecycle |

---

## Domain Effects by Command

When a domain is set, commands generate **additional safety-critical sections** specific to the regulatory standard. This is implemented via the **Domain Overlay Architecture** introduced in v0.6.0.

### Overlay Assembly Protocol

Setting `domain:` in `v-model-config.yml` triggers an assembly protocol at the start of each command's System Prompt:

1. **Read** `v-model-config.yml` and detect the `domain:` field value
2. **Locate** the matching overlay directory: `commands/overlays/{domain}/`
3. **Load** the `_domain.yml` manifest — lists the applicable commands and the standard's classification system (ASIL, DAL, or Safety Class)
4. **Inject** the domain-specific instruction file for that command (e.g., `commands/overlays/iso_26262/requirements.md`) into the relevant command sections
5. **Generate** output with both best-practice and domain-specific content merged

When `domain:` is empty, steps 2–4 are skipped and only best-practice content is generated.

### Overlay Directory Structure

```
commands/overlays/
├── iso_26262/
│   ├── _domain.yml          ← manifest: domain name, classification system, applicable commands
│   ├── requirements.md      ← ASIL allocation, derived safety requirements, safety mechanisms
│   ├── acceptance.md        ← ASIL-dependent verification methods (Table 11), back-to-back testing
│   ├── system-design.md     ← FFI, Restricted Complexity, safety mechanisms allocation
│   ├── system-test.md       ← MC/DC targets, WCET verification, structural coverage by ASIL
│   ├── architecture-design.md ← ASIL Decomposition, Defensive Programming, Temporal Constraints
│   ├── integration-test.md  ← SIL/HIL Compatibility, Resource Contention
│   ├── module-design.md     ← MISRA C/C++, Complexity Limits (≤ 10), Memory Management
│   ├── unit-test.md         ← MC/DC Coverage, Variable-Level Fault Injection
│   ├── hazard-analysis.md   ← HARA, ASIL severity classification (S×E×C)
│   ├── trace.md             ← ASIL-dependent coverage, bidirectional traceability
│   ├── peer-review.md       ← Review rigor by ASIL (walkthrough → formal inspection)
│   ├── impact-analysis.md   ← Safety impact assessment, ASIL re-evaluation
│   ├── audit-report.md      ← Functional safety audit, confirmation measures
│   └── test-results.md      ← ASIL coverage metrics (Table 12), test evidence
├── do_178c/
│   └── ... (same structure — DAL A–E classification)
└── iec_62304/
    └── ... (same structure — Class A–C classification)
```

### Domain Content by Command Category

| Command | ISO 26262 Adds | DO-178C Adds | IEC 62304 Adds |
|---------|---------------|--------------|----------------|
| `requirements` | ASIL allocation + decomposition, derived safety requirements, safety mechanisms | DAL traceability, derived requirements, robustness by DAL | Safety class–dependent rigor, risk analysis input |
| `acceptance` | ASIL-dependent verification methods (Table 11), back-to-back testing | Requirements-based + robustness testing, structural coverage by DAL | Safety class test completeness, regression |
| `system-design` | Freedom from Interference (FFI), Restricted Complexity, safety mechanisms allocation | Partitioning, data/control coupling, derived requirements | Architecture + risk control traceability |
| `system-test` | MC/DC targets, WCET verification, structural coverage by ASIL | Structural coverage by DAL (A–C) | Testing by safety class |
| `architecture-design` | ASIL Decomposition (Part 9 §5), Defensive Programming | DAL-driven verification, partitioning by DAL | Architecture by safety class, interface documentation |
| `integration-test` | SIL/HIL Compatibility, Resource Contention, back-to-back | Hardware fidelity by DAL, integration verification | Integration testing by safety class |
| `module-design` | MISRA C/C++, Complexity Limits (≤ 10), Memory Management | CERT-C, Single Entry/Exit, Complexity by DAL | Detailed design by safety class, coding standards |
| `unit-test` | MC/DC Coverage, Variable-Level Fault Injection | Structural coverage by DAL, MC/DC for DAL A | Verification by safety class, robustness testing |
| `hazard-analysis` | HARA, ASIL severity classification (S×E×C) | FHA, failure condition classification (ARP 4761) | Software safety classification A–C (ISO 14971) |

### `iso_26262` — Automotive (ISO 26262)

| Command | Additional Sections |
|---------|-------------------|
| `system-design` | Freedom from Interference (FFI) analysis, Restricted Complexity |
| `system-test` | Structural Coverage (MC/DC) targets, WCET verification |
| `architecture-design` | ASIL Decomposition (safety integrity allocation), Defensive Programming |
| `integration-test` | SIL/HIL Compatibility (Software/Hardware-in-the-Loop), Resource Contention |
| `module-design` | Complexity Limits (cyclomatic ≤ 10), Memory Management (no dynamic allocation after init), MISRA/CERT-C compliance |
| `unit-test` | MC/DC Coverage (each condition independently affects decision), Variable-Level Fault Injection |

### `do_178c` — Aerospace (DO-178C)

| Command | Additional Sections |
|---------|-------------------|
| `system-design` | Freedom from Interference (FFI) analysis, Restricted Complexity |
| `system-test` | Structural Coverage (MC/DC) targets, WCET verification |
| `architecture-design` | ASIL Decomposition, Temporal Constraints |
| `integration-test` | SIL/HIL Compatibility, Resource Contention |
| `module-design` | Single Entry/Exit enforcement, Memory Management, Complexity Limits |
| `unit-test` | MC/DC Coverage, Variable-Level Fault Injection |

### `iec_62304` — Medical Devices (IEC 62304)

| Command | Additional Sections |
|---------|-------------------|
| `system-design` | Freedom from Interference (FFI) analysis, Restricted Complexity |
| `system-test` | Structural Coverage (MC/DC) targets, WCET verification |
| `architecture-design` | ASIL Decomposition, Defensive Programming |
| `integration-test` | SIL/HIL Compatibility, Resource Contention |
| `module-design` | Complexity Limits (cyclomatic ≤ 10), Memory Management |
| `unit-test` | MC/DC Coverage, Variable-Level Fault Injection |

---

## Domain Comparison Matrix

| Section | `iso_26262` | `do_178c` | `iec_62304` |
|---------|:-----------:|:---------:|:-----------:|
| FFI Analysis | ✅ | ✅ | ✅ |
| Restricted Complexity | ✅ | ✅ | ✅ |
| MC/DC Targets | ✅ | ✅ | ✅ |
| WCET Verification | ✅ | ✅ | ✅ |
| ASIL Decomposition | ✅ | ✅ | ✅ |
| Defensive Programming | ✅ | — | ✅ |
| Temporal Constraints | — | ✅ | — |
| SIL/HIL Compatibility | ✅ | ✅ | ✅ |
| Resource Contention | ✅ | ✅ | ✅ |
| Complexity Limits (≤ 10) | ✅ | ✅ | ✅ |
| Memory Management | ✅ | ✅ | ✅ |
| MISRA/CERT-C Compliance | ✅ | — | — |
| Single Entry/Exit | — | ✅ | — |
| MC/DC Coverage | ✅ | ✅ | ✅ |
| Variable-Level Fault Injection | ✅ | ✅ | ✅ |

---

## Behavior Summary

| Scenario | Result |
|----------|--------|
| Config file **absent** | Treated as `domain: ""` — non-regulated mode |
| Config present, `domain: ""` | Same as absent — no safety-critical sections |
| Config present, `domain: "iso_26262"` | Commands generate ISO 26262-specific sections |
| Config present, `domain: "do_178c"` | Commands generate DO-178C-specific sections |
| Config present, `domain: "iec_62304"` | Commands generate IEC 62304-specific sections |

!!! tip "Non-Regulated Projects"
    If you are not building for a regulated domain, you do not need a `v-model-config.yml` file at all. The extension works without it.

---

## Example Configurations

### Non-Regulated (Default)

No configuration file needed. Alternatively:

```yaml
# v-model-config.yml
domain: ""
```

### Automotive ADAS Project (ISO 26262)

```yaml
# v-model-config.yml — Automotive ADAS
domain: "iso_26262"
```

This triggers:

- `/speckit.v-model.system-design` adds **Freedom from Interference** (FFI) and **Restricted Complexity** sections
- `/speckit.v-model.system-test` adds **Structural Coverage** (MC/DC) and **Resource Usage Testing** (WCET, stack, heap) sections
- `/speckit.v-model.architecture-design` adds **ASIL Decomposition** and **Defensive Programming** sections
- `/speckit.v-model.integration-test` adds **SIL/HIL Compatibility** and **Resource Contention** sections
- `/speckit.v-model.module-design` adds **Complexity Limits** (≤ 10), **Memory Management**, and **MISRA/CERT-C** sections
- `/speckit.v-model.unit-test` adds **MC/DC Coverage** and **Variable-Level Fault Injection** sections

### Aerospace Flight Controller (DO-178C)

```yaml
# v-model-config.yml — Aerospace DAL-A
domain: "do_178c"
```

### Medical Device Software (IEC 62304)

```yaml
# v-model-config.yml — Class C Medical Device
domain: "iec_62304"
```

---

## Rationale

!!! abstract "Why Opt-In?"
    Safety-critical analysis sections are mandatory under ISO 26262, DO-178C, and IEC 62304 but create noise for non-regulated projects. The opt-in approach keeps the default experience clean while enabling full regulatory compliance when needed. The configuration file is Git-tracked, making the decision auditable.
