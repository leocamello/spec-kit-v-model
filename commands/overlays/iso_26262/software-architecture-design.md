# Software Architecture Design — ISO 26262 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iso_26262`.
> It provides domain-specific ASPICE SWE.2 process guidance for the base `software-architecture-design` command.

## ASPICE SWE.2 Integration

> **Reference**: ASPICE v3.1 SWE.2 — Software Architectural Design
> **Purpose**: To establish an analyzed software architecture, comprising static and dynamic aspects, consistent with the software requirements.
> **Scope**: This overlay applies **only** when `domain: iso_26262`. Other regulated domains (`do_178c`, `iec_62304`) use their own overlays and do NOT trigger SWE.2 sections.

The following nine Base Practices (BP1–BP9) SHALL be addressed in the generated `software-architecture-design.md`. Each BP output maps to a subsection in the artifact.

### SWE.2.BP1 — Develop Software Architectural Design

Document the software architecture design developed from `requirements.md`. The output SHALL include:

- A description of how the architecture design was derived from requirements
- Key design decisions and their rationale
- The architecture pattern employed (e.g., pipeline, layered, event-driven)
- IEEE 42010 views as the structural framework

Guidance for generation:
- Reference the Logical View for static decomposition
- Reference the Process View for dynamic behavior
- Summarize the design approach in 3–5 paragraphs

### SWE.2.BP2 — Allocate Software Requirements

Map every `REQ-NNN` from `requirements.md` to one or more `ARCH-NNN` elements. The output SHALL include:

- A table with columns: Requirement ID, Allocated Architecture Elements, Allocation Rationale
- Every REQ-NNN SHALL appear in at least one row
- Each allocation SHALL include a brief rationale explaining why that ARCH element satisfies the requirement
- Non-functional requirements (REQ-NF-NNN) SHALL also be allocated

### SWE.2.BP3 — Define Interfaces of Software Elements

Document the interfaces and contracts for every `ARCH-NNN` element. The output SHALL include:

- For each architecture element: interface name, direction (Input/Output/Bidirectional), protocol, input format, output format, error handling strategy
- Distinction between internal (element-to-element) and external (file I/O, CLI) interfaces
- A summary paragraph identifying the most critical interfaces and their contracts
- Cross-reference the Interface View for full contract details

### SWE.2.BP4 — Describe Dynamic Behavior

Document the runtime interactions, concurrency model, and state transitions. The output SHALL include:

- Sequence diagrams (Mermaid `sequenceDiagram`) showing key interaction flows
- Description of the concurrency model (single-threaded pipeline, multi-threaded, async)
- Synchronization points and decision branches (e.g., domain-gated SWE.2 generation)
- Cross-reference the Process View for full interaction details

### SWE.2.BP5 — Define Resource Consumption Objectives

Document resource budgets and constraints. The output SHALL include a table with columns: Resource, Objective, Rationale. Cover at minimum:

- **CPU**: Wall-clock time budget for the full pipeline
- **Memory**: Peak memory usage for the expected input size
- **Latency**: End-to-end generation time target
- **Throughput**: Artifacts per invocation (if applicable)
- **Storage**: Expected output file size range

Each objective SHALL map to a success criterion (SC-NNN) from the feature spec where applicable.

### SWE.2.BP6 — Evaluate Alternative Software Architectures

Document candidate architectures considered and justify the chosen design. The output SHALL include a table with columns: Alternative, Description, Evaluation, Decision. Include at minimum:

- The chosen architecture with justification
- At least one rejected alternative with rationale
- At least one deferred alternative (for future consideration)
- Document trade-offs (simplicity vs extensibility, performance vs modularity)

### SWE.2.BP7 — Establish Bidirectional Traceability

Confirm that every `ARCH-NNN` links back to one or more `REQ-NNN` and vice versa. The output SHALL include:

- Forward traceability statement: every REQ-NNN is allocated to ≥1 ARCH-NNN
- Backward traceability statement: every ARCH-NNN has ≥1 parent REQ-NNN
- Coverage metrics: total REQs, total ARCHs, forward coverage %, backward coverage %
- Cross-reference the Traceability Summary section

### SWE.2.BP8 — Ensure Consistency

Confirm that all architecture descriptions are coherent with requirements. The output SHALL document:

- How the strict translator constraint is enforced (no invented elements)
- How derived items (`[DERIVED MODULE]`, `[DERIVED REQUIREMENT]`) are flagged for review
- How lifecycle rules preserve consistency across regenerations
- How the template structure prevents structural drift
- Cross-reference the Derived Requirements/Modules sections

### SWE.2.BP9 — Communicate Agreed Software Architectural Design

Summarize how the architecture design is communicated and agreed upon. The output SHALL document:

- That the artifact is version-controlled in Git (cryptographic audit trail)
- That it is reviewable as plaintext Markdown (diffable, no proprietary tooling)
- That it is consumable by downstream V-Model commands (`integration-test` prefers it over `architecture-design.md`)
- The criteria for considering the design "agreed" (derived items reviewed, traceability 100%, SWE.2 score ≥ 90%, committed to branch)

### SWE.2 Compliance Checklist

| BP | Practice | Required Content | Verification |
|----|----------|-----------------|--------------|
| BP1 | Develop architectural design | Architecture overview, design decisions, pattern | Section populated, ≥3 paragraphs |
| BP2 | Allocate requirements | REQ → ARCH table with rationale | Every REQ-NNN allocated |
| BP3 | Define interfaces | Interface summary, critical contracts identified | Cross-reference Interface View |
| BP4 | Describe dynamic behavior | Sequence diagrams, concurrency model | Cross-reference Process View |
| BP5 | Resource objectives | CPU, memory, latency, throughput, storage table | Each resource has an objective |
| BP6 | Evaluate alternatives | Comparison table with chosen/rejected/deferred | ≥1 rejected, ≥1 deferred |
| BP7 | Bidirectional traceability | Forward + backward coverage statements | 100% REQ→ARCH, 100% ARCH→REQ |
| BP8 | Ensure consistency | Translator constraint, derived items, lifecycle | Consistency statement present |
| BP9 | Communicate design | Version control, reviewability, agreement criteria | Communication summary present |
