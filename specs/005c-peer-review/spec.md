# Feature 005c: Peer Review Command

## Problem Statement

In regulated software development (medical devices, automotive, aerospace), every V-Model artifact must be peer-reviewed before approval. Human reviewers spend hours checking if requirements are testable, if designs have complete interfaces, if test plans cover all required techniques, and if hazard analyses have adequate mitigations. This manual review process is expensive, inconsistent across reviewers, and often catches structural issues late — after significant downstream work has already been built on a flawed artifact.

There is no automated first-pass reviewer that can catch standards-based quality issues before a human reviewer sees the artifact. Engineers submit artifacts directly for human review, wasting expert reviewer time on problems that could have been flagged mechanically.

## Proposed Solution

Add a `/speckit.v-model.peer-review` command that acts as an **AI-powered, stateless linter** for any V-Model artifact. The command reads a single artifact, evaluates it against standards-based review criteria specific to that artifact type, and produces a structured review report with findings.

### Key Characteristics

1. **AI-generated review** — The LLM evaluates prose quality, structural completeness, standards compliance, and cross-reference integrity. This is not a deterministic script; it requires natural language understanding to assess whether a requirement is "testable" or a severity classification is "reasonable."

2. **Stateless linting model** — Operates like ESLint or SonarQube, not like Jira. There is no `Status: Open` field. If a finding appears in the report, it is a current problem. If the engineer fixes the issue and re-runs the command, the finding disappears. The review file is regenerated each run; `git diff` shows what changed between reviews.

3. **Per-artifact-type review criteria** — Each artifact type is evaluated against the standard that governs it:
   - `requirements.md` → INCOSE Guide for Writing Requirements (atomic, testable, unambiguous, complete, no subjective language, priority assigned)
   - `system-design.md` → IEEE 1016 (all 4 views present, every SYS traces to ≥1 REQ, interface contracts complete, derived requirements flagged)
   - `architecture-design.md` → IEEE 42010 / Kruchten 4+1 (4+1 views populated, CROSS-CUTTING modules justified, interface definitions complete)
   - `system-test.md` → ISO 29119 (named techniques used correctly, no user-journey language, scenario independence)
   - `integration-test.md` → ISO 29119-4 (CDCT technique present, fault injection scenarios, interface coverage)
   - `module-design.md` → DO-178C / ISO 26262 (4 mandatory views present, algorithm specs complete, error handling defined)
   - `unit-test.md` → ISO 29119-4 (5 techniques present, mock registry complete, boundary values explicit)
   - `hazard-analysis.md` → ISO 14971 / ISO 26262 (severity classifications reasonable, every HAZ has mitigation, operational state coverage, residual risk assessed)
   - `acceptance-plan.md` → ISO 29119 (BDD scenarios well-formed, validation conditions measurable, coverage of parent REQs)

4. **Advisory-only findings** — `PRF-{ARTIFACT}-NNN` IDs are NOT part of the traceability chain. They live in their own document and do not affect coverage metrics. Peer review findings are transient (they get resolved); trace IDs are permanent.

5. **Severity classification**:
   - **Critical** — Blocks release. Fundamental quality violation (untestable requirement, missing mandatory view, unmitigated catastrophic hazard).
   - **Major** — Should fix before approval. Significant quality issue (ambiguous quantifier, incomplete interface, missing test technique).
   - **Minor** — Nice to fix. Style or completeness issue that does not affect correctness (inconsistent formatting, missing rationale on low-risk item).
   - **Observation** — Informational. Suggestion for improvement, not a defect (alternative decomposition strategy, additional test technique that could add value).

6. **CI-hookable exit codes** — A small deterministic parser script reads the generated review and returns:
   - Exit 0 — Clean (zero findings, or observations only)
   - Exit 1 — Critical or Major findings detected (blocks PR merge)
   - Exit 2 — Minor findings only (warning, does not block)

7. **Cross-cutting** — Works on any artifact at any time. Review requirements before writing system design, or review unit-test after everything is done. No ordering dependency.

### Output Format

The command produces `peer-review-{artifact}.md` containing:
- **Header** — Reviewer identification, date, artifact name, artifact item count, governing standard
- **Summary table** — Finding counts by severity
- **Findings section** — One subsection per finding with: PRF ID, Severity, Location (specific artifact ID), Description, Recommendation

### CI Integration

The `peer-review-check.sh` / `peer-review-check.ps1` parser script:
- Reads a `peer-review-{artifact}.md` file
- Counts findings by severity (parses the summary table or individual finding headers)
- Returns exit code 0, 1, or 2
- Supports `--json` flag to output finding counts as structured JSON
- Can be wired into GitHub Actions or any CI system as a pre-merge gate

### What Is NOT In Scope

- **Automated fixing** — The command identifies issues but does not modify the original artifact
- **Traceability chain participation** — PRF IDs are advisory-only, never referenced by trace matrices
- **Cross-artifact review** — Each invocation reviews a single artifact. To review multiple, invoke the command multiple times
- **Historical tracking** — No database of past findings. Git history provides the audit trail of what was found and when it was resolved

## User Scenarios & Testing

### User Story 1 — Review Requirements Before Design (Priority: P1)

A systems engineer has completed `requirements.md` with 15 REQ-NNN items for a medical device. Before proceeding to system design, she runs `/speckit.v-model.peer-review requirements.md`. The command evaluates each requirement against INCOSE quality attributes and produces `peer-review-requirements.md` with 7 findings: 1 Critical (untestable requirement using subjective language), 3 Major (ambiguous quantifiers, missing priorities), 2 Minor (formatting), 1 Observation (suggested decomposition). She fixes the Critical and Major findings, re-runs, and gets a clean report.

**Independent Test**: Run the command on a requirements.md with known quality issues (subjective language, ambiguous quantifiers). Verify findings are generated with correct PRF IDs, severities, and locations.

### User Story 2 — CI Gate for Pull Requests (Priority: P1)

A development team adds `peer-review-check.sh` to their GitHub Actions workflow. When an engineer opens a PR that modifies `hazard-analysis.md`, the CI pipeline runs the peer review and the check script. The check script finds 2 Major findings (unmitigated hazard, missing operational state) and returns exit 1, blocking the PR merge. The engineer addresses the findings, pushes, CI re-runs, and the review is clean (exit 0).

**Independent Test**: Create a peer review file with known Critical/Major/Minor findings. Run the check script and verify exit codes match expectations (1 for Critical/Major, 2 for Minor only, 0 for clean).

### User Story 3 — Review Design Artifacts (Priority: P1)

An architect runs peer review on `system-design.md` after completing the initial design. The review checks IEEE 1016 compliance: are all 4 design views present? Does every SYS trace to at least one REQ? Are interface contracts complete? The report flags a SYS component with no parent REQ link and an interface view missing error response codes.

**Independent Test**: Run on a system-design.md with intentional gaps (missing view, orphaned SYS). Verify the review catches each gap.

### User Story 4 — Review Hazard Analysis (Priority: P2)

A safety engineer runs peer review on `hazard-analysis.md`. The review checks ISO 14971 compliance: are severity classifications reasonable? Does every HAZ have a mitigation? Is residual risk assessed? Are operational states covered? The review flags a hazard with "Low" severity for a patient-harm failure mode and a missing mitigation for a Catastrophic hazard.

**Independent Test**: Run on a hazard-analysis.md with known issues. Verify severity assessment findings and mitigation gap findings.

### User Story 5 — Idempotent Re-run After Fix (Priority: P2)

An engineer fixes all Critical and Major findings from a previous peer review. She re-runs the command. The regenerated report shows 0 Critical, 0 Major, and only the 2 Minor findings that she chose not to address yet. The CI check script returns exit 2 (warning). She merges the PR.

**Independent Test**: Run peer review on a "clean" artifact that meets all standards criteria. Verify zero Critical/Major findings and appropriate exit code.
