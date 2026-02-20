# V-Model Methodology Overview

## What is the V-Model?

The **V-Model** (Verification and Validation model) is a software development lifecycle (SDLC) model that emphasizes a strict, disciplined sequence: for every development phase, there is a directly corresponding testing phase. Instead of a linear waterfall, the process forms a **"V" shape** — development phases descend on the left, implementation sits at the bottom, and testing phases ascend on the right.

## Core Principle: Verification vs. Validation

- **Verification (Left Side):** "Are we building the product *right*?" — Reviews of documents, design, and code.
- **Validation (Right Side):** "Are we building the *right* product?" — Dynamic testing and execution.

The defining characteristic: **test plans are designed simultaneously with their corresponding development phase**, not after coding is complete.

## The V-Model Phases

```
Requirements ←————————————————————→ Acceptance Testing
    ↘                                      ↗
  System Design ←——————————————→ System Testing
      ↘                              ↗
    Architecture ←————————→ Integration Testing
        ↘                        ↗
      Module Design ←——→ Unit Testing
            ↘            ↗
          Implementation
```

### Left Side (Development/Verification)

| Phase | Output | Paired Test Phase |
|-------|--------|-------------------|
| **Requirements Analysis** | Requirement Specification | Acceptance Testing |
| **System Design** | System Design Document | System Testing |
| **Architectural Design** | High-Level Design | Integration Testing |
| **Module Design** | Low-Level Design | Unit Testing |

### Right Side (Testing/Validation)

| Phase | Validates | What It Tests |
|-------|-----------|---------------|
| **Unit Testing** | Module Design | Individual functions, classes, methods |
| **Integration Testing** | Architecture | Module interfaces, API contracts |
| **System Testing** | System Design | Complete system: performance, security, load |
| **Acceptance Testing** | Requirements | End-to-end user scenarios |

## Why the V-Model Matters for AI-Assisted Development

Modern AI coding tools ("vibe coding") often generate code without structured test plans, making it difficult to:
- Prove that every requirement was tested
- Trace a test failure back to a specific requirement
- Demonstrate compliance with safety standards

The V-Model Extension Pack enforces discipline by **requiring paired generation**: every development artifact (specification) automatically generates its testing counterpart (test plan), with traceable IDs linking them.

## The Three-Tier ID Schema

This extension uses a hierarchical ID scheme that encodes traceability directly:

| Tier | ID Format | Example | Meaning |
|------|-----------|---------|---------|
| Requirement | `REQ-NNN` | REQ-001 | A discrete, testable requirement |
| Test Case | `ATP-NNN-X` | ATP-001-A | A logical test condition for REQ-001 |
| Scenario | `SCN-NNN-X#` | SCN-001-A1 | An executable BDD scenario for ATP-001-A |

Reading `SCN-001-A1` tells you: this scenario validates test case `ATP-001-A`, which tests requirement `REQ-001`. No lookup table needed.

## System Design ↔ System Testing Level

The second V-Model layer pairs **System Design** (left side) with **System Testing** (right side). While the Requirements ↔ Acceptance Testing level validates *what* the system must do, this level validates *how* the system is structured to do it.

### Standards Alignment

- **IEEE 1016:2009** (Software Design Description) defines 4 design viewpoints used to describe the system design:
  - **Decomposition View** — System broken into components/modules
  - **Dependency View** — Relationships and coupling between components
  - **Interface View** — External and internal interface contracts
  - **Data Design View** — Data models, schemas, and data flow

- **ISO 29119-4** (Test Techniques) specifies systematic techniques for system-level testing:
  - **Interface Contract Testing** — Validates interface specifications from the Interface View
  - **Boundary Value Analysis** — Tests edge cases for data ranges and limits
  - **Fault Injection** — Verifies error handling and resilience paths
  - **Equivalence Partitioning** — Groups inputs into classes to reduce test cases while maintaining coverage

### System-Level ID Schema

| Tier | ID Format | Example | Meaning |
|------|-----------|---------|---------|
| Design Element | `SYS-NNN` | SYS-001 | A discrete system design element |
| Test Procedure | `STP-NNN-X` | STP-001-A | A test procedure for SYS-001 |
| Test Step | `STS-NNN-X#` | STS-001-A1 | An executable test step for STP-001-A |

Reading `STS-001-A1` tells you: this step validates test procedure `STP-001-A`, which tests design element `SYS-001`. The same self-documenting lineage as the requirements level.

## When to Use the V-Model

The V-Model is ideal when:
- **Requirements are well-defined** and unlikely to change significantly
- **Regulatory compliance** is required (medical, automotive, aerospace, industrial)
- **Safety is critical** — software failures could harm people or property
- **Audit trails** are mandatory — you need to prove every requirement was tested
- **The technology stack is known** — no major technical exploration needed

## Further Reading

- IEEE 29148:2018 — Systems and software engineering — Life cycle processes — Requirements engineering
- INCOSE Guide for Writing Requirements (2017)
- DO-178C — Software Considerations in Airborne Systems
- ISO 26262 — Road vehicles — Functional safety
- IEC 62304 — Medical device software — Software life cycle processes
- IEC 61508 — Functional safety of electrical/electronic/programmable electronic safety-related systems
