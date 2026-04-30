# ARCH-008: Additive Enrichment Encoder

<!-- v-model-enrichment: feature=007-bridge-commands -->
<!-- source: architecture-design.md §Interface View ARCH-008 -->

**Module Type**: Pure transform  
**Target Source File**: `src/v_model_extension/shared/enrichment.py` (MOD-011 / MOD-012)  
**Invoked by**: ARCH-001 (plan), ARCH-003 (tasks)

---

## Interface Contract

| Direction | Name | Type | Format | Constraints |
|-----------|------|------|--------|-------------|
| Input | `canonical_doc` | string | canonical Markdown | MUST validate against the corresponding spec-kit-core schema before enrichment |
| Input | `metadata` | struct | `{trace_chains[], optional_sections{}}` | empty metadata → identity transform |
| Output | `enriched_doc` | string | canonical Markdown + HTML comments + optional sections | MUST still validate against the spec-kit-core schema after enrichment |
| Exception | `EnrichmentError` | raised | text | when the input `canonical_doc` is itself non-conformant |

## Additive-Only Guarantee

ARCH-008 is **strictly additive**: it may only insert HTML comments and
optional Markdown sections. It MUST NOT modify, reorder, or delete any
content that was present in `canonical_doc`. The post-enrichment document
MUST pass ARCH-013 schema validation.
