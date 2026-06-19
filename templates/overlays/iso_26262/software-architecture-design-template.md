# Software Architecture Design — ISO 26262 Template Overlay

> This template overlay is loaded when `v-model-config.yml` sets `domain: iso_26262`.
> It appends ASPICE SWE.2 process guidance sections to the base `software-architecture-design-template.md`.

## ASPICE SWE.2 Process Guidance

> This section is included because the domain is configured as `iso_26262`. SWE.2 BP1–BP9 documents the software architectural design process for ISO 26262 compliance.

### SWE.2.BP1 — Develop Software Architectural Design

[Document how the architecture design was developed from requirements. Include key design decisions and the architecture pattern employed.]

### SWE.2.BP2 — Allocate Software Requirements

[Map requirements to architecture elements and explain allocation rationale.]

| Requirement | Allocated Architecture Elements | Rationale |
|-------------|-------------------------------|-----------|
| REQ-NNN | ARCH-NNN, ARCH-NNN | [Why this allocation] |

### SWE.2.BP3 — Define Interfaces of Software Elements

[Describe the key interfaces and contracts for architecture elements. Cross-reference the Interface View for full contract details.]

### SWE.2.BP4 — Describe Dynamic Behavior

[Describe the runtime interactions and state transitions. Cross-reference the Process View for full interaction details.]

### SWE.2.BP5 — Define Resource Consumption Objectives

[Document CPU, memory, latency, throughput, and storage constraints.]

| Resource | Objective | Rationale |
|----------|-----------|-----------|
| CPU | [Objective] | [Rationale] |
| Memory | [Objective] | [Rationale] |
| Latency | [Objective] | [Rationale] |
| Throughput | [Objective] | [Rationale] |
| Storage | [Objective] | [Rationale] |

### SWE.2.BP6 — Evaluate Alternative Software Architectures

[Compare candidate architecture alternatives and justify the chosen design.]

| Alternative | Description | Evaluation | Decision |
|-------------|-------------|------------|----------|
| [Alternative A] | [Description] | [Evaluation] | Chosen / Rejected / Deferred |

### SWE.2.BP7 — Establish Bidirectional Traceability

[Confirm forward traceability (every REQ has ≥1 ARCH) and backward traceability (every ARCH has ≥1 REQ). Cross-reference the Traceability Summary for metrics.]

### SWE.2.BP8 — Ensure Consistency

[Confirm the architecture is coherent with requirements. Document how the strict translator constraint and derived item flagging ensure consistency.]

### SWE.2.BP9 — Communicate Agreed Software Architectural Design

[Summarize how the architecture design is communicated and agreed upon: version control, reviewability, downstream consumability, and agreement criteria.]
