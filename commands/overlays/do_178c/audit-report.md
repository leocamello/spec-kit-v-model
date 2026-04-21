# Audit Report — DO-178C Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: do_178c`.
> It provides domain-specific software quality assurance and certification liaison sections for the base `audit-report` command.

## Software Quality Assurance Audit (DO-178C §8)

DO-178C §8 requires the SQA function to independently verify that the software lifecycle processes conform to the approved plans and standards. When generating the audit report in a DO-178C project, the report must include an **SQA Audit** section verifying:

| SQA Objective (§8.2) | Evidence Source | DAL Applicability | Finding |
|----------------------|-----------------|-------------------|---------|
| Software plans comply with DO-178C | Software Development Plan, Software Verification Plan | A, B, C, D | ✅ / ❌ / ⚠️ |
| Software standards are defined and followed | Coding standards referenced in `module-design.md` overlay | A, B, C | ✅ / ❌ / ⚠️ |
| Software lifecycle activities conform to plans | `requirements.md`, `system-design.md`, test artifacts | A, B, C, D | ✅ / ❌ / ⚠️ |
| Deviations from plans are documented and approved | `waivers.md` WAV-NNN entries | A, B, C, D | ✅ / ❌ / ⚠️ |
| Transition criteria between lifecycle phases are met | Phase exit checklists or traceability matrix coverage | A, B, C | ✅ / ❌ / ⚠️ |
| Software conformity review completed prior to release | SQA sign-off record | A, B, C, D | ✅ / ❌ / ⚠️ |

**Rules**:
- SQA activities at DAL A–B require **independence** — the SQA auditor must not be the developer of the reviewed artifact
- A ❌ finding against any DAL A objective is a **major nonconformity** — it blocks release and must be reported to the certification authority
- Record each ⚠️ finding with a corrective action item and target closure date

## Certification Liaison Audit (DO-178C §9 — SOI Reviews)

DO-178C §9 requires that the applicant coordinate with the certification authority at defined Stage of Involvement (SOI) milestones. Verify the following SOI review status in the audit report:

| SOI Review | DO-178C §9 Ref | Review Point | Required Artifacts | Status |
|-----------|---------------|-------------|-------------------|--------|
| SOI-1 | §9.2 | After planning phase | Software plans, standards, tool qualification plans | ✅ Complete / ⏳ Pending / ❌ Overdue |
| SOI-2 | §9.3 | After development phase (before verification) | Requirements, design, code, traceability — first pass | ✅ Complete / ⏳ Pending / ❌ Overdue |
| SOI-3 | §9.4 | After verification phase | Verification results, coverage data, problem reports closed | ✅ Complete / ⏳ Pending / ❌ Overdue |
| SOI-4 | §9.5 | Final review (pre-approval) | Software Accomplishment Summary (SAS), all lifecycle data | ✅ Complete / ⏳ Pending / ❌ Overdue |

**Rules**:
- An ❌ Overdue SOI review must be escalated to the certification liaison immediately — it is a **major nonconformity**
- If an SOI review was conducted but findings remain open, list each open finding with its resolution plan and responsible party
- The SOI-4 review requires that the Software Accomplishment Summary (SAS) is complete and references all lifecycle data items — verify its existence and completeness

## Problem Report Closure Verification (DO-178C §8.1)

DO-178C §8.1 requires that software problem reports (PRs) are tracked to closure before release. Verify PR closure status:

| Problem Report Category | Count Open | Count Closed | Deferred (with approval)? | Release Gate |
|------------------------|-----------|-------------|--------------------------|-------------|
| Safety-critical (DAL A–B impact) | [N] | [N] | Yes / No | Must be zero open |
| Non-safety (DAL C–D impact) | [N] | [N] | Yes / No | Deferred PRs require CCB approval |

- Reference each open safety-critical PR by ID in the audit report Findings section
- Deferred non-safety PRs must have a WAV-NNN entry with CCB approval documented
