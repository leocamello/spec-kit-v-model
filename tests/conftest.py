# Implements: REQ-NF-002, SYS-006, ARCH-009, D-008
"""Minimal pytest configuration stub.

Per Phase 1 / T003 of the v0.7.0 task list this file exists only to expose
the ``tests/`` directory as a Python package root and to make the canonical
ID set discoverable from any test family. The bulk of the work is in
``tests/helpers/load_canonical_ids.sh``; this file is intentionally tiny so
the GREEN phase can grow it without churn.
"""

from __future__ import annotations

import os
import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SPECS_ROOT = REPO_ROOT / "specs"

_CANONICAL_PATTERN = re.compile(
    r"\b("
    r"REQ|SYS|ARCH|MOD|"
    r"ITP|ITS|UTP|UTS|STP|STS|ATP|SCN|HAZ"
    r")(-[A-Z]{2,3})?"
    r"-[0-9]+(-[A-Z][0-9]*)?\b"
)
# Sub-prefix slot (-[A-Z]{2,3})? generalises the prior REQ-NF/REQ-CN/REQ-IF
# enumeration to every root the project actually uses derived categories
# under (REQ-DR, REQ-LC, REQ-SEC, SYS-DR, ATP-NF/CN/IF/LC, SCN-NF/CN/IF/LC,
# STP-NF). Inventory taken 2026-05-17.


def load_canonical_ids(feature: str) -> set[str]:
    """Return the canonical V-Model ID set for ``specs/<feature>/v-model/``.

    Mirrors the POSIX helper at ``tests/helpers/load_canonical_ids.sh`` so
    that Python-based tests (DeepEval / structural pytest) and shell-based
    tests (BATS / Pester) share a single source of truth per D-008.
    """
    vmodel_dir = SPECS_ROOT / feature / "v-model"
    ids: set[str] = set()
    if not vmodel_dir.is_dir():
        return ids
    for md in sorted(vmodel_dir.glob("*.md")):
        for match in _CANONICAL_PATTERN.finditer(md.read_text(encoding="utf-8")):
            ids.add(match.group(0))
    return ids


# Convenience re-export for IDE discoverability.
__all__ = ["REPO_ROOT", "SPECS_ROOT", "load_canonical_ids"]

# Honour CI-injected feature pin if present (no-op otherwise).
DEFAULT_FEATURE = os.environ.get("V_MODEL_FEATURE", "007-bridge-commands")
