# Product Vision: V-Model at the Speed of AI

## The Core Problem: The Unstructured AI vs. Compliance Chasm

A seismic shift is underway in software development. AI-assisted coding tools have unlocked unprecedented velocity — developers can generate entire modules, refactor systems, and ship features in hours instead of weeks. This new paradigm of **unstructured AI code generation** — sometimes called "vibe coding" in developer communities — prioritizes rapid iteration guided by intent rather than formal specification.

This velocity comes at a cost that most teams don't notice until it's too late.

**The speed side** produces code without structured test plans. There is no way to prove that every requirement was tested. There is no way to trace a field failure back to a specific requirement that was missed or misunderstood. The artifacts that auditors, regulators, and quality teams need simply don't exist — because the workflow never created them.

**The compliance side** faces the opposite problem. Regulated industries — medical devices, automotive safety systems, avionics — are bound by standards that demand full traceability between requirements, design, and test evidence. Teams invest in heavy Application Lifecycle Management (ALM) platforms like IBM DOORS, Jama Connect, or Siemens Polarion, and still spend weeks manually cross-referencing requirement IDs against test case IDs, hunting for coverage gaps by hand. A single requirement change can cascade into days of rework across multiple documents — even with enterprise tooling.

The result is a chasm:

| | AI-Native Teams | Regulated Teams |
|---|---|---|
| **Speed** | Hours per feature | Weeks per feature |
| **Traceability** | None | Manual, error-prone |
| **Audit readiness** | Not applicable | Months of prep |
| **Requirement coverage** | Unknown | Manually verified |
| **Cost of change** | Low (code) | Extreme (documentation) |

Both sides lose. Fast teams ship without proof of correctness. Compliant teams move too slowly to compete. Neither has a workflow where rigor and velocity coexist.

## The Vision: Rigor and Velocity Are No Longer Mutually Exclusive

The V-Model Extension Pack for Spec Kit exists to close this chasm.

Our thesis is simple: **the V-Model's core discipline — every development artifact has a simultaneously generated, paired testing artifact — can be enforced at AI speed without sacrificing the traceability that regulators demand.**

The extension treats the specification as the ultimate source of truth. From a single set of requirements, it generates:

1. **Formal requirements** with traceable IDs (`REQ-NNN`) — atomized, categorized, and auditable per IEEE 29148.
2. **Paired acceptance test plans** with three tiers of traceability — test cases (`ATP-NNN-X`) linked to requirements, and executable BDD scenarios (`SCN-NNN-X#`) linked to test cases.
3. **A deterministic traceability matrix** that mathematically proves 100% bidirectional coverage — no orphaned tests, no untested requirements, no manual cross-referencing.

What previously took a compliance team weeks to assemble is generated in minutes and validated in seconds. When a requirement changes, the downstream test cases and traceability matrix are regenerated — not manually patched.

This is not about replacing human judgment. The AI acts as an **exoskeleton for the systems engineer** — it drafts exhaustive requirements and test cases at machine speed, but the human expert reviews, refines, and commits them. No safety parameter is set by AI autonomously. Every artifact is reviewed before it becomes part of the verified baseline.

And because every artifact is plaintext Markdown stored in Git, the entire specification history is backed by **cryptographic commit hashes** — an immutable, mathematically verifiable audit trail of who changed what and when. Git becomes the Quality Management System (QMS): every requirement change, every test case update, every traceability matrix regeneration is versioned, diffable, and attributable. No ALM database required for the audit trail — `git log` provides it.

## Value Proposition by Industry

### Medical Devices — IEC 62304 & FDA 21 CFR Part 820

Medical device software is classified by risk (Class A, B, or C under IEC 62304), and higher risk classes demand complete traceability between software requirements, architecture, and verification. FDA's Quality System Regulation (21 CFR Part 820 §820.30) requires design validation evidence linking every requirement to its verification.

**The traditional workflow**: A team building a patient vital signs monitor maintains requirements in a Word document, test cases in a separate spreadsheet, and a traceability matrix in yet another spreadsheet. When a requirement changes — say, a blood pressure alarm threshold is updated — an engineer must manually update the requirement, find all linked test cases, update each one, rebuild the matrix, and have it reviewed. This process takes days and is the primary bottleneck in pre-submission audits.

**With V-Model Extension Pack**: The team runs `/speckit.v-model.requirements` to atomize their specification into traceable `REQ-NNN` items. `/speckit.v-model.acceptance` generates paired test cases (`ATP-NNN-X`) and executable BDD scenarios (`SCN-NNN-X#`) for each requirement. `/speckit.v-model.trace` builds the traceability matrix deterministically — regex-based scripts (not AI self-assessment) guarantee that coverage calculations are mathematically correct. When the alarm threshold changes, the team regenerates the affected artifacts. The matrix updates in seconds, not days.

For teams already invested in ALM platforms like Jama Connect or IBM DOORS, the generated Markdown artifacts serve as an accelerator — draft-quality requirements and test plans produced in minutes, ready for expert review and import into the team's existing system of record. We recognize that introducing a second artifact source risks fragmenting the source of truth — a serious audit violation. Our roadmap includes bidirectional synchronization with enterprise ALM platforms, ensuring that the velocity gained in the Git repository is seamlessly reflected in the enterprise system of record. For startups and smaller teams without enterprise ALM budgets, the artifacts live natively in Git and are audit-ready as-is.

### Automotive — ISO 26262

ISO 26262 governs functional safety for road vehicles. Part 6, Clause 9 requires verification of software units against their requirements, with traceability evidence proportional to the Automotive Safety Integrity Level (ASIL A through D). ASIL-D systems — such as autonomous emergency braking — demand the most rigorous traceability.

**The challenge**: An ADAS team developing emergency braking must prove that every safety requirement (detection latency, braking force thresholds, false positive rates) has a corresponding test case, and that every test case traces back to a requirement. Orphaned tests or untested requirements are audit findings.

**With V-Model Extension Pack**: The three-tier ID schema (`REQ-NNN` → `ATP-NNN-X` → `SCN-NNN-X#`) creates self-documenting lineage. The traceability matrix explicitly flags orphaned test cases (tests with no parent requirement) and uncovered requirements (requirements with no test case). The deterministic validation scripts provide the mathematical proof that ISO 26262 assessors require — not an AI's opinion, but a regex-verified fact.

### Aerospace — DO-178C

DO-178C (Software Considerations in Airborne Systems and Equipment Certification) is among the most demanding software standards in existence. Section 6.3.4 requires bidirectional traceability: forward (requirement → test) and backward (test → requirement). Certification authorities (FAA, EASA) expect this traceability to be demonstrably complete.

**With V-Model Extension Pack**: The `/speckit.v-model.trace` command produces both forward and backward traceability views in a single matrix. The deterministic build script cross-references every `REQ-NNN` against its `ATP-NNN-X` entries and every `SCN-NNN-X#` against its parent test case. Gaps are surfaced immediately — before a Designated Engineering Representative (DER) review, not during one.

### From Test Plans to Test Execution

The V-Model Extension Pack currently covers the planning side of the V — from requirements through acceptance test plans and traceability verification. But an auditor doesn't just want to see the test *plan*; they want to see test *results* executed against actual code.

This is where the BDD scenario format pays off. Because every scenario (`SCN-NNN-X#`) is generated in standard Given/When/Then structure, these scenarios are directly ingestible by automated test frameworks — Cucumber, Behave, Jest, PyTest-BDD, or SpecFlow. The generated scenarios become the bridge between the planning artifacts (which prove completeness) and the execution logs (which prove correctness).

The extension's roadmap includes deeper integration with implementation and test execution (see [Future Roadmap](#the-future-roadmap)), but the architecture is designed from day one to connect the top of the V (what must be tested) to the bottom (what was actually tested).

On the development side of the V, traceability extends into the codebase itself. When the AI agent generates implementation code guided by the requirements, it can be instructed to embed requirement IDs in code comments (e.g., `// Implements REQ-001`) and commit messages. This provides the final link in the chain of custody: from requirement, through test plan, into source code — all versioned in Git and traceable by ID.

### Open Source & Enterprise — Eliminating Technical Debt of Intent

Not every project faces regulatory audits, but every project faces the same fundamental question: **is what we built what we intended to build?**

The gap between intent and implementation — what we call the "technical debt of intent" — grows silently. Requirements live in issue trackers, test cases live in test files, and no one can prove they align. Six months later, a test fails and no one knows which requirement it validates, or a feature is cut and orphaned tests remain in the suite forever.

The V-Model Extension Pack brings the same structured traceability to any project that values knowing, with certainty, that every requirement has a test and every test has a purpose. The overhead is minutes, not months — and the payoff is a `specs/` directory that serves as living proof of what was specified, what was tested, and what was verified.

## The Architectural Philosophy: Trust Through Separation of Concerns

A compliance tool that uses AI for everything cannot be trusted for compliance. If an AI generates the traceability matrix and also evaluates whether it's correct, you have a system grading its own homework.

The V-Model Extension Pack enforces a strict separation of concerns:

| Responsibility | Handled By | Why |
|---|---|---|
| **Creative translation** — turning specifications into structured requirements and test scenarios | AI (LLM agent) + **Human review** | Requires understanding of domain context and natural language interpretation. The human expert must verify the fidelity of derived `REQ-NNN` items against the original intent — the tool ensures structural completeness; the human ensures semantic correctness. This step is the most critical review gate: a hallucinated threshold (e.g., 250ms instead of 150ms) would propagate structurally perfect but functionally dangerous artifacts downstream. |
| **Coverage calculation** — determining whether every requirement has a test case | Deterministic scripts (regex + Bash/PowerShell) | Must be mathematically correct; AI "hallucinations" are unacceptable for compliance metrics |
| **Matrix generation** — building the traceability table with forward/backward links | Deterministic scripts | Structural correctness is verifiable by inspection; no probabilistic reasoning needed |
| **Gap detection** — identifying orphaned tests, uncovered requirements, missing scenarios | Deterministic scripts | Binary yes/no decisions that must be reproducible across runs |
| **Quality evaluation** — assessing whether requirements are well-written and scenarios are comprehensive | LLM-as-judge (DeepEval + Gemini) | Qualitative assessment where human-like judgment adds value; clearly labeled as advisory, not deterministic |
| **Audit trail** — proving who changed what and when | Git (cryptographic commit hashes) | Immutable, mathematically verifiable history; no separate ALM database required |

This architecture means that when you present a traceability matrix to an auditor, the coverage numbers were computed by a script that can be inspected, tested (27 BATS tests, 27 Pester tests), and verified — not by an AI that might produce a different answer on the next run.

The AI does what AI is good at: understanding context and generating structured content. The scripts do what scripts are good at: producing the same correct answer every time.

## The Future Roadmap

The V-Model Extension Pack's MVP covers the top of the V-Model (Requirements ↔ Acceptance Testing). The roadmap extends coverage down the V and adds capabilities that regulated teams have asked for:

### Deeper V-Model Coverage
- **System Design ↔ System Testing** — Generate system design documents from requirements and paired system test plans.
- **Architecture ↔ Integration Testing** — Produce component architecture specs with interface contracts and integration test plans.
- **Module Design ↔ Unit Testing** — Create detailed module designs with paired unit test specifications.
- **Implementation Gating** — Enforce that all upstream artifacts exist and pass coverage checks before implementation begins.

### Regulatory Accelerators

The MVP provides universal structural traceability — traceable IDs, bidirectional matrices, and deterministic coverage validation — that satisfies the core traceability requirements of all major safety standards. The regulatory accelerators below will add domain-specific boilerplate and workflows on top of this foundation:

- **Pre-built Regulatory Template Packs** — Domain-specific templates for IEC 62304, ISO 26262, and DO-178C that pre-populate the required sections, terminology, and compliance language for each standard (e.g., automatically inserting ASIL-D or Class C specific verbiage into requirement templates).
- **Change Impact Analysis** — When a requirement changes, automatically identify every downstream artifact (test cases, scenarios, matrix entries) that requires re-validation. Eliminates the manual "what else does this affect?" search.
- **Hazard Analysis Integration** — Link requirements directly to hazard mitigations, supporting FMEA (Failure Mode and Effects Analysis) workflows where every identified hazard must trace to a mitigation requirement and a verification test.
- **Bidirectional ALM Synchronization** — Two-way sync with enterprise ALM platforms (Jama Connect, IBM DOORS, Siemens Polarion), eliminating the risk of fragmented sources of truth between Git and the enterprise system of record.

### Quality Intelligence
- **Compliance Report Generator** — Produce a single audit-ready report aggregating requirements coverage, test results, traceability completeness, and gap analysis into the format that assessors expect.
- **Trend Tracking** — Monitor requirement quality scores, coverage percentages, and traceability completeness over time to catch degradation before it becomes a finding.

---

The V-Model Extension Pack is not a documentation generator. It is a discipline enforcer — one that proves rigor and velocity can coexist, that AI-native speed and safety-critical compliance are not opposing forces, and that the gap between what is specified and what is tested can be closed permanently.

The AI drafts. The human decides. The scripts verify. Git remembers.
