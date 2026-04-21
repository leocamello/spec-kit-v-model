# Impact Analysis — DO-178C Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: do_178c`.
> It provides domain-specific change control and problem reporting sections for the base `impact-analysis` command.

## Problem Report Linkage (DO-178C §7.1)

DO-178C §7.1 requires that software problems are reported and tracked through a formal problem reporting process. When running impact analysis in a DO-178C project, every changed ID must be linked to a Problem Report (PR) or Change Request (CR) before the change is incorporated:

| Changed ID | DAL | Problem Report / CR Reference | Problem Category | CCB Approved? |
|-----------|-----|-------------------------------|-----------------|---------------|
| REQ-NNN | DAL [A–E] | PR-NNN / CR-NNN | [Category 1: Safety / Category 2: Functional / Category 3: Cosmetic] | Yes / No / N/A |
| MOD-NNN | DAL [A–E] | PR-NNN / CR-NNN | [Category 1: Safety / Category 2: Functional / Category 3: Cosmetic] | Yes / No / N/A |

**Problem Categories** (DO-178C §7.1):
- **Category 1**: Problem that could cause failure of a function required for safe flight — must be resolved before release
- **Category 2**: Problem that degrades system performance but does not cause unsafe conditions — may be deferred with CCB approval
- **Category 3**: Problem with no operational impact (typos, formatting) — may be deferred

**Rules**:
- Every changed ID at DAL A–C must reference an approved PR or CR — unlinked changes are a **major nonconformity**
- Category 1 problems must be resolved before SOI-3 review; open Category 1 PRs block release
- The problem report must document: problem description, steps to reproduce, DAL of affected item, and proposed resolution

## Change Impact Assessment (DO-178C §7 — Change Control Board)

DO-178C §7 requires that the impact of every approved change is assessed against all affected lifecycle data. Extend the base command's blast radius with DAL-specific re-verification scope:

| Affected Item | DAL | Impact Scope | Re-verification Required | Independence Required? |
|--------------|-----|-------------|------------------------|----------------------|
| REQ-NNN | DAL A | Full re-verification: requirements review, structural coverage, traceability | Yes — all Table A-4 objectives | Yes (DAL A) |
| REQ-NNN | DAL B | Requirements review + regression testing | Yes — applicable Table A-4/A-7 objectives | Yes (DAL A–B) |
| REQ-NNN | DAL C | Requirements review + confirmation that tests still pass | Yes — applicable objectives | No |
| REQ-NNN | DAL D | Confirmation review | Recommended | No |

**Rules**:
- A change to a derived requirement (`[DERIVED]` tag) must be fed back to the system safety assessment — notify the certification liaison before proceeding
- If the change introduces a **new derived requirement**, the SOI-2 review must be re-opened or a partial SOI-2 supplement submitted to the certification authority
- Changes to DAL A software tools (compilers, code generators) require tool qualification re-assessment per DO-178C §12

## Re-verification Scope by DAL (DO-178C §6.3.4 Bidirectional Traceability)

For each suspect artifact identified by the base command, determine the re-verification scope based on DAL:

| DAL | Structural Coverage Required | Minimum Re-verification Activities |
|-----|-----------------------------|------------------------------------|
| A | MC/DC (Modified Condition / Decision Coverage) | Regression of all tests tracing to changed item; MC/DC report updated |
| B | Decision coverage | Regression of decision-covering tests; coverage report updated |
| C | Statement coverage | Regression of statement-covering tests; coverage report updated |
| D | Not required | Functional test re-run sufficient; no structural coverage data needed |

- For each affected test artifact (UTP-NNN, ITP-NNN, STP-NNN, ATP-NNN), confirm the coverage level achieved after re-verification still meets the DAL threshold
- Document re-verification results in the traceability matrix — update the `[SUSPECT]` tag to `[ACTIVE — Re-verified: PR-NNN]` once re-verification is complete
