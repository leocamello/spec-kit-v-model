# ARCH-014: Reduced-Enrichment Fallback

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-014 -->

**Module Type**: Detector  
**Target Source File**: `src/v_model_extension/shared/enrichment.py` (MOD-011)  
**Invoked by**: ARCH-003 (Stage 2), ARCH-004 (Stage 2)

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `upstream_doc` | string | canonical Markdown | e.g. a `plan.md` |
| Output | `EnrichmentReport` | struct | `{enriched: bool, missing_metadata_keys: [str]}` | `enriched: false` ⟹ caller populates from V-Model artifacts directly |
| Exception | `UpstreamParseError` | raised | text + path + line | when `upstream_doc` is not valid UTF-8 Markdown or cannot be parsed for enrichment markers (truncated, unexpected schema variant, non-UTF-8 byte sequence); propagated fail-closed |

## Error-Recovery Semantics

A successfully parsed `upstream_doc` whose enrichment metadata is merely
**absent** yields `EnrichmentReport{enriched: false, missing_metadata_keys: [...]}`.
This is **NOT** an error — the Hybrid path proceeds via the fallback branch
in ARCH-003 / ARCH-004.

Only structural parse failure raises `UpstreamParseError`.

## Key Acceptance Scenario

- SCN-009-B1: plain `speckit.plan` output consumed; warning emitted; exit 0
