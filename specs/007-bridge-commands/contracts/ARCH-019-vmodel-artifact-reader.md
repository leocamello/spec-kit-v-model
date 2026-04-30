# ARCH-019 [CROSS-CUTTING]: V-Model Artifact Reader

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-019 -->

**Module Type**: Cross-cutting input reader  
**Target Source File**: `src/v_model_extension/shared/artifact_reader.py` (MOD-024 / MOD-025)  
**Invoked by**: ARCH-001, ARCH-003, ARCH-004

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `feature_dir` | path | absolute path | |
| Output | `ArtifactSet` | struct | `{requirements, acceptance_plan, system_design, system_test, architecture_design, integration_test, module_design, unit_test, hazard_analysis, traceability_matrix}` | each field nullable; nulls flow through to graceful-degradation decisions in callers |
| Output | `vmodel_id_set` | set[string] | union of every REQ/ATP/SCN/SYS/STP/STS/ARCH/ITP/ITS/MOD/UTP/UTS/HAZ ID present | includes IDs tagged `[DEPRECATED]` and `[SUSPECT]` |
| Exception | `MalformedArtifact` | raised | path + reason | propagated as fatal |

## Notes

`vmodel_id_set` is the **authoritative ID universe** consumed by ARCH-009.
It is constructed by applying the SYS-006 regex across **all** V-Model
artifact files, including deprecated entries, so that the hallucination guard
correctly accepts IDs that appear in the source but are no longer active.
