# Research: System Design ↔ System Testing

**Branch**: `002-system-design-testing`
**Date**: 2026-02-20
**Status**: Complete

## Research Questions

### RQ-1: How should many-to-many REQ↔SYS relationships be represented in plaintext Markdown?

**Finding**: Each `SYS-NNN` component includes a "Parent Requirements" field listing all parent `REQ-NNN` identifiers as a comma-separated list. This encodes the many-to-many relationship directly in the document without requiring a separate mapping table or database. The `validate-system-coverage.sh` script parses this field via regex to compute forward coverage (every REQ has ≥1 SYS) and detect orphaned components.

**Decision**: Comma-separated REQ-NNN list in the Decomposition View's "Parent Requirements" column.

**Rationale**: Consistent with the v0.1.0 approach where ATP IDs embed their parent REQ number. Keeps all traceability data in the Markdown file itself, satisfying Constitution Principle IV (Git as QMS).

**Alternatives considered**:
- Separate mapping table in the same file: Rejected — duplicates information and creates sync risk.
- JSON sidecar file: Rejected — violates Constitution Principle IV (all compliance-critical artifacts in plaintext Markdown).
- Parent field in each view: Rejected — redundant. Decomposition View is the single source; other views reference SYS-NNN IDs.

### RQ-2: What IEEE 1016 design views are mandatory for the system-design command?

**Finding**: IEEE 1016:2009 defines multiple viewpoints for software design descriptions. For the system design level (decomposing requirements into components), four views are most relevant and provide complete architectural coverage:

1. **Decomposition View** — How the system is partitioned into subsystems and components. Lists SYS-NNN identifiers with name, description, and parent REQ-NNN references.
2. **Dependency View** — Inter-component relationships and failure propagation paths. Critical for safety analysis (ISO 26262 FFI).
3. **Interface View** — API contracts, data formats, communication protocols, and hardware-software boundaries. Directly feeds interface contract testing (ISO 29119).
4. **Data Design View** — Data structures, storage mechanisms, and data protection measures. Covers data-at-rest and data-in-transit security.

**Decision**: All four views mandatory in `system-design.md`. Template enforces section headers for each.

**Rationale**: IEEE 1016 does not mandate a fixed set of views but requires that the selected viewpoints be justified. These four cover the decomposition, dependency, interface, and data dimensions needed for both safety analysis and test generation.

**Source**: IEEE 1016:2009 §5 (Design viewpoints), ISO 26262-6 §7 (Software architectural design).

### RQ-3: How should ISO 29119 test techniques be applied in system test cases?

**Finding**: ISO 29119-4 (Test Techniques) defines a catalog of test design techniques. For system-level testing derived from a design document, three technique families are most applicable:

1. **Interface Contract Testing** — Verifies that components honor their published API contracts. Must distinguish between:
   - *External interfaces* (user-facing APIs): Focus on protocol compliance, authentication, error responses.
   - *Internal interfaces* (inter-module): Focus on contract adherence, data format correctness, failure propagation.
2. **Boundary Value Analysis / Equivalence Partitioning** — Tests data limits, thresholds, and ranges documented in the Data Design View.
3. **Fault Injection / Negative Testing** — Tests failure propagation paths documented in the Dependency View. Verifies error handling, graceful degradation, and isolation between components.

**Decision**: Each `STP-NNN-X` test case must identify its ISO 29119 technique by name. The test case must also reference which IEEE 1016 design view it targets.

**Rationale**: Named techniques force rigorous, auditor-grade test design. The technique-to-view linkage creates a traceable chain: View → Technique → Test Case → Scenario.

**Source**: ISO/IEC/IEEE 29119-4:2021 (Test Techniques), ISO 29119-3:2021 (Test Documentation).

### RQ-4: How should safety-critical sections (FFI, MC/DC, WCET) be gated?

**Finding**: Safety-critical analysis sections are mandatory under ISO 26262 and DO-178C but irrelevant for non-regulated projects. Including them by default would create noise for general-purpose users.

**Decision**: Gate via `v-model-config.yml` at the project root. When `domain` is set to a regulated standard identifier (`iso_26262`, `do_178c`, `iec_62304`), the commands generate additional sections:
- System design: Freedom from Interference (FFI) analysis, Restricted Complexity assessment
- System test: MC/DC test obligations, WCET verification scenarios

When the config is absent or the domain field is empty, these sections are omitted entirely.

**Rationale**: Opt-in activation prevents cognitive overload for non-regulated teams while ensuring regulated teams get the full analysis required by their standards. The config file is Git-tracked, making the decision auditable.

**Alternatives considered**:
- Command-line flag: Rejected — not persistent; would need to be specified on every invocation.
- Always generate, let users delete: Rejected — creates noise and violates the "minimal necessary output" principle.
- Separate commands for safety-critical mode: Rejected — doubles the command surface area without added value.

**Source**: ISO 26262-6 §7.4.8 (Freedom from Interference), DO-178C §6.4.4.2 (Structural Coverage Analysis).

### RQ-5: How should derived requirements be handled during system design decomposition?

**Finding**: During system design, the AI may identify a technical capability that is necessary for the architecture but was not explicitly stated in `requirements.md`. In safety-critical standards (DO-178C §5.1.1, ISO 26262-6 §7.4.1), these are called "derived requirements" and must be formally traced and approved.

**Decision**: The system design command flags derived requirements with `[DERIVED REQUIREMENT: description]` in the output instead of silently creating a `SYS-NNN` component. The human must decide whether to:
1. Add the capability to `requirements.md` (creating a new REQ-NNN)
2. Reject it as unnecessary
3. Merge it into an existing requirement

**Rationale**: Silent addition of SYS-NNN components for undocumented capabilities breaks the strict translator constraint (Constitution Principle V, FR-018/019) and creates orphaned components that fail coverage validation.

**Source**: DO-178C §5.1.1 (Derived Requirements), ISO 26262-8 §6.4.4 (Impact analysis of changes).

### RQ-6: How should the dual-matrix traceability output be structured?

**Finding**: With two V-levels (Requirements ↔ Acceptance and System Design ↔ System Testing), a single traceability matrix becomes visually complex. Enterprise ALM tools (IBM DOORS, Jama Connect) present validation and verification traceability as separate views.

**Decision**: The extended `/speckit.v-model.trace` command produces two separate tables:
- **Matrix A (Validation)**: REQ → ATP → SCN — proves the system does what the user needs.
- **Matrix B (Verification)**: REQ → SYS → STP → STS — proves the architecture works as designed.

Each matrix includes an independently calculated coverage percentage verified by its corresponding deterministic script.

**Rationale**: Separate tables prevent a single wide matrix with 7+ columns from becoming unreadable in Markdown. Coverage percentages are independently verifiable by different scripts, maintaining audit independence.

**Alternatives considered**:
- Single merged matrix (REQ → ATP → SCN → SYS → STP → STS): Rejected — too wide for Markdown, mixes validation and verification concerns.
- Three separate matrices (one per V-level pair): Premature — only two levels exist now. Easy to add Matrix C when Phase 5b ships.

### RQ-7: How should validate-system-coverage.sh handle the many-to-many REQ↔SYS relationship?

**Finding**: Unlike v0.1.0's validate-requirement-coverage.sh (which validates 1:N REQ→ATP mapping), the system-level script must handle many-to-many:
- A single REQ may map to multiple SYS components
- A single SYS may satisfy multiple REQs
- Forward coverage: every REQ must appear as a parent in at least one SYS
- Backward coverage: every SYS must have at least one STP test case

**Decision**: The script builds two associative arrays:
1. Parse `system-design.md` Decomposition View: extract each SYS-NNN and its "Parent Requirements" list → populate `req_to_sys` map (REQ→SYS[]) and `sys_exists` set.
2. Parse `system-test.md`: extract each STP-NNN-X → populate `sys_to_stp` map (SYS→STP[]).
3. Forward check: iterate all REQ-NNN from `requirements.md`; verify each appears in `req_to_sys`.
4. Backward check: iterate all SYS-NNN from `sys_exists`; verify each appears in `sys_to_stp`.
5. Orphan check: verify all SYS parent REQs exist in `requirements.md`; verify all STP parent SYS exist in `system-design.md`.

**Rationale**: Associative arrays (Bash 4+) provide O(1) lookup for coverage verification. The three-pass approach (parse, cross-reference, report) is consistent with `validate-requirement-coverage.sh`'s architecture.

**Source**: `validate-requirement-coverage.sh` implementation patterns, Constitution Principle II.

### RQ-8: What STS scenario language style distinguishes system tests from acceptance tests?

**Finding**: Both acceptance scenarios (SCN) and system test scenarios (STS) use Given/When/Then BDD format, but their language register must differ:
- **SCN (acceptance)**: User-centric language. "Given a logged-in user, When they submit a form, Then they see a confirmation."
- **STS (system test)**: Technical, component-oriented language. "Given the database connection pool is exhausted, When a new query is submitted, Then the system returns error code 503 within 200ms."

**Decision**: The system-test command prompt explicitly mandates technical language and prohibits user-journey phrases ("the user clicks", "the user sees", "the user navigates") in STS scenarios.

**Rationale**: System tests verify architectural behavior, not user journeys. The language distinction makes it immediately clear to auditors which V-level a test belongs to.

**Source**: ISO 29119-3 (Test Documentation — test case specification levels), BDD community best practices for layered testing.
