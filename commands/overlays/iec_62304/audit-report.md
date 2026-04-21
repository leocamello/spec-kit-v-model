# Audit Report — IEC 62304 Domain Overlay

> This overlay is loaded when `v-model-config.yml` sets `domain: iec_62304`.
> It provides domain-specific configuration management audit and problem resolution sections for the base `audit-report` command.

## Configuration Management Audit (IEC 62304 §8)

IEC 62304 §8 requires that configuration management (CM) is applied throughout the software lifecycle. When generating the audit report in an IEC 62304 project, the report must include a **CM Audit** section verifying:

| CM Objective (IEC 62304 §8) | Evidence Source | Safety Class Applicability | Finding |
|-----------------------------|-----------------|---------------------------|---------|
| All software items are identified and version-controlled | Git SHA pinned in audit report header | A, B, C | ✅ / ❌ / ⚠️ |
| Change requests are documented before changes are made | `waivers.md` WAV-NNN or change request log | B, C | ✅ / ❌ / ⚠️ |
| Approved changes are reflected in updated V-Model artifacts | Traceability matrix — modified REQ-NNN/MOD-NNN are re-verified | B, C | ✅ / ❌ / ⚠️ |
| Software release baseline is reproducible from recorded versions | Git tag resolves to the exact artifact set in the report | A, B, C | ✅ / ❌ / ⚠️ |
| Configuration status accounting records are complete | Lifecycle status summary in §3.1 of audit report | B, C | ✅ / ❌ / ⚠️ |

**Rules**:
- A ❌ finding against a Class C objective is a **major nonconformity** — it indicates the device cannot demonstrate a controlled software baseline to a regulatory body (FDA, MDR/IVDR)
- Class A artifacts require only identification and version control (items 1 and 4) — the other CM objectives are mandatory for Class B–C only
- CM audit findings must be included in the device's risk management file as part of the overall safety case

## Problem Resolution Tracking (IEC 62304 §9)

IEC 62304 §9 requires a documented problem resolution process for software anomalies. Verify that all open problems are tracked and resolved before release:

| Problem Category | Safety Class | Count Open | Resolution Deadline | Escalation Required? |
|-----------------|-------------|-----------|---------------------|---------------------|
| Safety-critical anomaly (risk control affected) | C | [N] | Before release | Yes — notify risk management |
| Functional anomaly (no safety impact) | B, C | [N] | Per project plan | No |
| Observation / informational | A, B, C | [N] | Next release cycle | No |

**Rules**:
- Any open problem that affects a software item implementing a **risk control measure** (traceable to HAZ-NNN) is safety-critical — it must be resolved before release regardless of safety class
- Unresolved safety-critical problems must be cross-referenced with the ISO 14971 risk management file to confirm residual risk is acceptable
- Deferred anomalies must have a WAV-NNN entry documenting the risk acceptance rationale and the approver's role (e.g., Quality Manager, Regulatory Affairs)
- Each WAV-NNN entry for a deferred problem must include: `**HAZ Reference**: HAZ-NNN` if the problem touches a risk control

## Safety Class Verification (IEC 62304 §8.1.1)

Verify that each software item's safety class assignment is current and supported by evidence:

| Software Item | Assigned Safety Class | Basis for Classification | Last Reviewed | Re-classification Needed? |
|--------------|----------------------|--------------------------|--------------|--------------------------|
| [Software item name] | Class [A/B/C] | [Hazard contribution — references HAZ-NNN or "No hazard contribution"] | [Date / Release] | Yes / No |

**Rules**:
- If any HAZ-NNN was added or modified since the last audit, re-evaluate the safety class of all software items that implement mitigations for that hazard
- A software item upgraded from Class A or B to Class C requires retrospective application of Class C lifecycle activities — document the gap analysis
- Safety class assignments are a regulatory submission artifact — changes must be traceable to a specific change request or impact analysis report
