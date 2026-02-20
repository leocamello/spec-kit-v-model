# System Design: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`
**Created**: [DATE]
**Status**: Draft
**Source**: `specs/[###-feature-name]/v-model/requirements.md`

## Overview

[Brief description of the system architecture and decomposition rationale]

## ID Schema

- **System Component**: `SYS-NNN` — sequential identifier for each component
- **Parent Requirements**: Comma-separated `REQ-NNN` list per component (many-to-many)
- Example: `SYS-003` with Parent Requirements `REQ-001, REQ-005` — component satisfies both requirements

## Decomposition View (IEEE 1016 §5.1)

<!--
  Each system component MUST have:
  - Unique ID: SYS-NNN (sequential, never renumbered)
  - Name: Short descriptive component name
  - Description: What this component does
  - Parent Requirements: Comma-separated REQ-NNN list (many-to-many mapping)
  - Type: Subsystem | Module | Service | Library | Utility

  RULES:
  - Every REQ-NNN must appear as a parent in at least one SYS-NNN
  - A SYS-NNN may have multiple parent REQs (many-to-many)
  - A REQ-NNN may be a parent of multiple SYS-NNNs (many-to-many)
  - Non-functional requirements (REQ-NF-NNN) map to cross-cutting components
  - Do NOT create SYS-NNN for capabilities not in requirements.md
  - Flag derived requirements with [DERIVED REQUIREMENT: description] instead
-->

| SYS ID | Name | Description | Parent Requirements | Type |
|--------|------|-------------|---------------------|------|
| SYS-001 | [Component Name] | [What it does] | REQ-001, REQ-002 | Subsystem |
| SYS-002 | [Component Name] | [What it does] | REQ-003 | Module |
| SYS-003 | [Component Name] | [What it does] | REQ-NF-001 | Service |

## Dependency View (IEEE 1016 §5.2)

<!--
  Document inter-component relationships and failure propagation paths.
  For each dependency:
  - Source: SYS-NNN that depends on the target
  - Target: SYS-NNN being depended upon
  - Relationship: Uses | Calls | Subscribes | Reads | Writes
  - Failure Impact: What happens to Source if Target fails
-->

| Source | Target | Relationship | Failure Impact |
|--------|--------|-------------|----------------|
| SYS-001 | SYS-002 | Calls | [Impact description] |
| SYS-003 | SYS-001 | Reads | [Impact description] |

### Dependency Diagram

```text
[ASCII or Mermaid dependency diagram]
```

## Interface View (IEEE 1016 §5.3)

<!--
  Document API contracts, data formats, and communication protocols.
  MUST distinguish between:
  - External interfaces: User-facing APIs, hardware boundaries
  - Internal interfaces: Inter-module communication

  For each interface:
  - Component: SYS-NNN exposing the interface
  - Interface Type: External | Internal
  - Protocol: REST | gRPC | File I/O | Shared Memory | etc.
  - Input: Data format and constraints
  - Output: Data format and constraints
  - Error Handling: How failures are communicated
-->

### External Interfaces

| Component | Interface Name | Protocol | Input | Output | Error Handling |
|-----------|---------------|----------|-------|--------|----------------|
| SYS-001 | [Name] | [Protocol] | [Format] | [Format] | [Error strategy] |

### Internal Interfaces

| Source | Target | Interface Name | Protocol | Data Format | Error Handling |
|--------|--------|---------------|----------|-------------|----------------|
| SYS-001 | SYS-002 | [Name] | [Protocol] | [Format] | [Error strategy] |

## Data Design View (IEEE 1016 §5.4)

<!--
  Document data structures, storage, and data protection.
  For each data entity:
  - Entity: Logical name
  - Component: SYS-NNN that owns/manages this data
  - Storage: In-memory | File | Database | Cache
  - Protection at Rest: Encryption, access control
  - Protection in Transit: TLS, signing, integrity checks
  - Retention: Lifecycle and cleanup policy
-->

| Entity | Component | Storage | Protection at Rest | Protection in Transit | Retention |
|--------|-----------|---------|-------------------|-----------------------|-----------|
| [Name] | SYS-001 | [Type] | [Method] | [Method] | [Policy] |

<!-- SAFETY-CRITICAL SECTION: Only include when v-model-config.yml domain is set -->

<!--
## Freedom from Interference (ISO 26262-6 §7.4.8)

| Component | ASIL Rating | Isolation Mechanism | Verification Method |
|-----------|-------------|--------------------|--------------------|
| SYS-NNN | ASIL [A-D] | [Memory partition / Time-slice / etc.] | [How verified] |

## Restricted Complexity (ISO 26262-6 §7.4.9)

| Component | Complexity Metric | Value | Threshold | Status |
|-----------|------------------|-------|-----------|--------|
| SYS-NNN | [Cyclomatic / Nesting / etc.] | [N] | [Max] | ✅/❌ |
-->

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total System Components (SYS) | [N] |
| Total Parent Requirements Covered | [N] / [N] ([%]) |
| Components per Type | Subsystem: [N] \| Module: [N] \| Service: [N] \| Library: [N] |
| **Forward Coverage (REQ→SYS)** | **[%]** |

## Derived Requirements

<!--
  List any [DERIVED REQUIREMENT: ...] flags here.
  Human must resolve before proceeding to system test generation.
  Options: (1) Add to requirements.md, (2) Reject, (3) Merge into existing REQ
-->

[List of derived requirements, or "None — all components trace to existing requirements."]

## Glossary

| Term | Definition |
|------|-----------|
| [Term] | [Definition] |
