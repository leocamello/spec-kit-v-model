# Implements: REQ-023, REQ-NF-002, REQ-NF-004, SYS-006, ARCH-009, MOD-013, MOD-025, D-008
"""D-008 hallucination-guard: canonical ID closure invariant (T024).

Re-runs the spec-kit-v-model hallucination guard programmatically as a
deterministic pytest:

    cited(commands/, specs/<feature>/ except v-model/)
        is-subset-of  canonical(specs/<feature>/v-model/)
                      union  {D-NNN from research.md}

Mirror of the shell-side ``scripts/bash/validate-implements-ids.sh`` and
the ``tests/conftest.py::load_canonical_ids`` Python helper. Failure
output enumerates each unknown ID with the file:line where it was cited
(per MOD-013 / MOD-025 reporting contract).
"""

from __future__ import annotations

import pathlib
import re

import pytest

from tests.conftest import REPO_ROOT, _CANONICAL_PATTERN, load_canonical_ids

SPECS_ROOT = REPO_ROOT / "specs"
COMMANDS_DIR = REPO_ROOT / "commands"

# D-NNN identifiers come from research.md (per D-008 closure rule).
_DECISION_RE = re.compile(r"\bD-\d+\b")
# Combined cite extractor: canonical V-Model IDs + decision IDs.
_CITE_RE = re.compile(rf"({_CANONICAL_PATTERN.pattern}|\bD-\d+\b)")


def _list_features() -> list[str]:
    if not SPECS_ROOT.is_dir():
        return []
    return sorted(
        p.name for p in SPECS_ROOT.iterdir()
        if p.is_dir() and (p / "v-model").is_dir()
    )


def _load_decisions(feature: str) -> set[str]:
    research = SPECS_ROOT / feature / "research.md"
    if not research.is_file():
        return set()
    return set(_DECISION_RE.findall(research.read_text(encoding="utf-8")))


def _scan_targets(feature: str) -> list[pathlib.Path]:
    """Markdown files under ``specs/<feature>/`` excluding ``v-model/``.

    ``commands/`` is global (shared by every feature) and therefore scanned
    separately against the **union** of canonical IDs across all features
    — see :func:`test_canonical_id_closure_global_commands`.
    """
    targets: list[pathlib.Path] = []
    feature_dir = SPECS_ROOT / feature
    vmodel_dir = feature_dir / "v-model"
    if feature_dir.is_dir():
        for md in sorted(feature_dir.rglob("*.md")):
            try:
                md.relative_to(vmodel_dir)
            except ValueError:
                targets.append(md)
            # else: under v-model/, skip (source of truth, not subject to guard)
    return targets


def _global_commands_targets() -> list[pathlib.Path]:
    if not COMMANDS_DIR.is_dir():
        return []
    return sorted(COMMANDS_DIR.rglob("*.md"))


def _global_canonical() -> set[str]:
    """Union of canonical IDs (V-Model + decisions) across every feature."""
    canon: set[str] = set()
    for feat in _list_features():
        canon |= load_canonical_ids(feat) | _load_decisions(feat)
    return canon


def _extract_cites_with_locations(
    paths: list[pathlib.Path],
) -> dict[str, list[tuple[pathlib.Path, int]]]:
    """Extract canonical-ID cites from ``Implements`` directives only.

    Mirrors ``scripts/bash/validate-implements-ids.sh`` exactly: the
    hallucination guard scans **only** ``Implements <ID>`` comments
    (case-insensitive), not body text — illustrative IDs in prose
    examples are intentionally exempt (per MOD-013, MOD-025; D-008).
    """
    cites: dict[str, list[tuple[pathlib.Path, int]]] = {}
    for path in paths:
        try:
            text = path.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError):
            continue
        for lineno, line in enumerate(text.splitlines(), start=1):
            if not re.search(r"[Ii]mplements[: ]", line):
                continue
            for m in _CITE_RE.finditer(line):
                cites.setdefault(m.group(0), []).append((path, lineno))
    return cites


@pytest.mark.structural
@pytest.mark.parametrize("feature", _list_features() or ["007-bridge-commands"])
def test_canonical_id_closure(feature: str):
    """D-008: per-feature non-vmodel Markdown cites only canonical IDs.

    Scans ``specs/<feature>/`` (excluding ``v-model/``) against
    ``canonical(<feature>) ∪ {D-NNN from <feature>/research.md}``.
    """
    canonical = load_canonical_ids(feature) | _load_decisions(feature)
    if not canonical:
        pytest.skip(f"feature {feature!r} has no canonical IDs to close against")

    targets = _scan_targets(feature)
    cites = _extract_cites_with_locations(targets)

    unknown = {cite: locs for cite, locs in cites.items() if cite not in canonical}
    if unknown:
        lines = [f"D-008 hallucination guard failed for feature {feature!r}:"]
        for cite in sorted(unknown):
            for path, lineno in unknown[cite][:5]:
                rel = path.relative_to(REPO_ROOT)
                lines.append(f"  unknown id {cite}  {rel}:{lineno}")
        pytest.fail("\n".join(lines))


@pytest.mark.structural
def test_canonical_id_closure_global_commands():
    """D-008: global ``commands/`` Implements directives cite a canonical ID.

    ``commands/`` is shared by every feature, so closure here is checked
    against the **union** of canonical IDs across all features (REQ-NF-002,
    MOD-013, MOD-025).
    """
    canonical = _global_canonical()
    if not canonical:
        pytest.skip("no features with canonical V-Model IDs found")

    targets = _global_commands_targets()
    if not targets:
        pytest.skip("commands/ directory is empty")
    cites = _extract_cites_with_locations(targets)

    unknown = {cite: locs for cite, locs in cites.items() if cite not in canonical}
    if unknown:
        lines = ["D-008 hallucination guard failed for global commands/:"]
        for cite in sorted(unknown):
            for path, lineno in unknown[cite][:5]:
                rel = path.relative_to(REPO_ROOT)
                lines.append(f"  unknown id {cite}  {rel}:{lineno}")
        pytest.fail("\n".join(lines))
