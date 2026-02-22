"""Deterministic structural validators for module-level V-Model artifacts."""

import re
from collections import Counter

# --- ID Patterns (inline match) ---

ID_PATTERNS = {
    "MOD": re.compile(r"MOD-[0-9]{3}"),
    "UTP": re.compile(r"UTP-[0-9]{3}-[A-Z]"),
    "UTS": re.compile(r"UTS-[0-9]{3}-[A-Z][0-9]+"),
}

# --- ID Patterns (strict full-match) ---

ID_STRICT_PATTERNS = {
    "MOD": re.compile(r"^MOD-[0-9]{3}$"),
    "UTP": re.compile(r"^UTP-[0-9]{3}-[A-Z]$"),
    "UTS": re.compile(r"^UTS-[0-9]{3}-[A-Z][0-9]+$"),
}

# --- Structural patterns ---

_MODULE_HEADING = re.compile(
    r"^###\s+Module:\s*(MOD-[0-9]{3})\s*\(([^)]+)\)", re.MULTILINE
)
_PARENT_ARCH_LINE = re.compile(
    r"^\*\*Parent Architecture Modules\*\*:\s*(.+)$", re.MULTILINE
)
_TARGET_SOURCE_LINE = re.compile(
    r"^\*\*Target Source File\(s\)\*\*:\s*(.+)$", re.MULTILINE
)
_EXTERNAL_TAG = re.compile(r"\[EXTERNAL\]")
_CROSS_CUTTING_TAG = re.compile(r"\[CROSS-CUTTING\]")
_STATELESS_BYPASS = re.compile(r"(?i)N/?A.*Stateless")
_PSEUDOCODE_BLOCK = re.compile(r"```pseudocode")
_STATE_DIAGRAM = re.compile(r"stateDiagram-v2")
_UTP_HEADING = re.compile(
    r"^####\s+Test Case:\s*(UTP-[0-9]{3}-[A-Z])\s*\(([^)]+)\)", re.MULTILINE
)
_UTS_LINE = re.compile(
    r"^\*\s+\*\*Unit Scenario:\s*(UTS-[0-9]{3}-[A-Z][0-9]+)\*\*", re.MULTILINE
)
_TECHNIQUE_LINE = re.compile(r"^\*\*Technique\*\*:\s*(.+)$", re.MULTILINE)
_MOCK_REGISTRY = re.compile(r"\*\*Dependency & Mock Registry", re.MULTILINE)
_EXTERNAL_BYPASS = re.compile(
    r"^>\s+Module MOD-[0-9]{3} is \[EXTERNAL\]", re.MULTILINE
)

# Module design required section headings per module
REQUIRED_MOD_VIEWS = [
    "Algorithmic / Logic View",
    "State Machine View",
    "Internal Data Structures",
    "Error Handling & Return Codes",
]

# Valid unit test technique names
VALID_TECHNIQUES = [
    "Statement & Branch Coverage",
    "Boundary Value Analysis",
    "Equivalence Partitioning",
    "Strict Isolation",
    "State Transition Testing",
    "MC/DC Coverage",
    "Variable-Level Fault Injection",
]


def extract_ids(text: str, prefix: str) -> list[str]:
    """Extract all IDs matching the given prefix (MOD, UTP, UTS) from text."""
    pattern = ID_PATTERNS.get(prefix)
    if pattern is None:
        raise ValueError(f"Unknown prefix: {prefix}. Must be one of: {', '.join(ID_PATTERNS)}")
    return pattern.findall(text)


def validate_id_format(ids: list[str], prefix: str) -> list[str]:
    """Return list of IDs that DON'T match the expected format. Empty = all valid."""
    pattern = ID_STRICT_PATTERNS.get(prefix)
    if pattern is None:
        raise ValueError(f"Unknown prefix: {prefix}. Must be one of: {', '.join(ID_STRICT_PATTERNS)}")
    return [id_ for id_ in ids if not pattern.match(id_)]


def find_duplicates(ids: list[str]) -> list[str]:
    """Return list of IDs that appear more than once."""
    counts = Counter(ids)
    return [id_ for id_, count in counts.items() if count > 1]


# --- Module Design validators ---


def extract_module_sections(text: str) -> list[dict]:
    """Parse module-design.md into structured module sections."""
    modules = []
    headings = list(_MODULE_HEADING.finditer(text))
    for i, m in enumerate(headings):
        start = m.start()
        end = headings[i + 1].start() if i + 1 < len(headings) else len(text)
        block = text[start:end]
        mod_id = m.group(1)
        mod_name = m.group(2)

        parent_match = _PARENT_ARCH_LINE.search(block)
        parent_archs = []
        if parent_match:
            parent_archs = re.findall(r"ARCH-[0-9]{3}", parent_match.group(1))

        target_match = _TARGET_SOURCE_LINE.search(block)
        target_files = target_match.group(1).strip() if target_match else ""

        is_external = bool(_EXTERNAL_TAG.search(block[:500]))
        is_cross_cutting = bool(_CROSS_CUTTING_TAG.search(block[:500]))
        has_pseudocode = bool(_PSEUDOCODE_BLOCK.search(block))
        has_state_diagram = bool(_STATE_DIAGRAM.search(block))
        is_stateless = bool(_STATELESS_BYPASS.search(block))

        present_views = []
        for view in REQUIRED_MOD_VIEWS:
            if view in block:
                present_views.append(view)

        modules.append({
            "id": mod_id,
            "name": mod_name,
            "parent_archs": parent_archs,
            "target_files": target_files,
            "is_external": is_external,
            "is_cross_cutting": is_cross_cutting,
            "has_pseudocode": has_pseudocode,
            "has_state_diagram": has_state_diagram,
            "is_stateless": is_stateless,
            "present_views": present_views,
        })
    return modules


def validate_module_design(design_text: str, arch_ids: list[str] | None = None) -> dict:
    """Run all module design validations.

    Args:
        design_text: Full text of module-design.md.
        arch_ids: Optional list of ARCH IDs from architecture-design.md for coverage check.
    """
    modules = extract_module_sections(design_text)
    mod_ids = [m["id"] for m in modules]
    unique_mods = list(dict.fromkeys(mod_ids))

    issues: list[str] = []
    scored_issue_count = 0

    # ID format validation
    bad = validate_id_format(unique_mods, "MOD")
    for b in bad:
        issues.append(f"Malformed MOD ID: {b}")
        scored_issue_count += 1

    # Duplicate check
    dupes = find_duplicates(mod_ids)
    for d in dupes:
        issues.append(f"Duplicate MOD ID: {d}")
        scored_issue_count += 1

    # Per-module structural checks
    for mod in modules:
        if mod["is_external"]:
            continue  # External modules have relaxed requirements

        # Pseudocode required for non-external modules
        if not mod["has_pseudocode"]:
            issues.append(f"{mod['id']}: Missing ```pseudocode block in Algorithmic / Logic View")
            scored_issue_count += 1

        # State machine: must have diagram OR stateless bypass
        if not mod["has_state_diagram"] and not mod["is_stateless"]:
            issues.append(
                f"{mod['id']}: State Machine View has neither stateDiagram-v2 "
                "nor N/A — Stateless bypass"
            )
            scored_issue_count += 1

        # Required views
        for view in REQUIRED_MOD_VIEWS:
            if view not in mod["present_views"]:
                issues.append(f"{mod['id']}: Missing '{view}' section")
                scored_issue_count += 1

        # Parent ARCH required
        if not mod["parent_archs"]:
            issues.append(f"{mod['id']}: Missing Parent Architecture Modules")
            scored_issue_count += 1

        # Target source file required
        if not mod["target_files"]:
            issues.append(f"{mod['id']}: Missing Target Source File(s)")
            scored_issue_count += 1

    # Forward coverage: every ARCH must have ≥1 MOD
    if arch_ids:
        covered_archs = set()
        for mod in modules:
            covered_archs.update(mod["parent_archs"])
        uncovered = [a for a in arch_ids if a not in covered_archs]
        for a in uncovered:
            issues.append(f"Uncovered ARCH (no MOD): {a}")
            scored_issue_count += 1

    # Backward coverage: every MOD's parent ARCH should exist
    if arch_ids:
        arch_set = set(arch_ids)
        for mod in modules:
            for parent in mod["parent_archs"]:
                if parent not in arch_set:
                    issues.append(f"Orphaned MOD parent: {mod['id']} references {parent} which is not in architecture-design.md")
                    scored_issue_count += 1

    total_items = max(len(unique_mods) * 4, 1)  # 4 checks per module (pseudo, state, views, parent)
    score = max(0.0, 1.0 - scored_issue_count / total_items)

    external_count = sum(1 for m in modules if m["is_external"])
    cross_cutting_count = sum(1 for m in modules if m["is_cross_cutting"])
    stateful_count = sum(1 for m in modules if m["has_state_diagram"])
    stateless_count = sum(1 for m in modules if m["is_stateless"])

    return {
        "score": round(score, 2),
        "issues": issues,
        "mod_ids": unique_mods,
        "modules": modules,
        "external_count": external_count,
        "cross_cutting_count": cross_cutting_count,
        "stateful_count": stateful_count,
        "stateless_count": stateless_count,
    }


# --- Unit Test validators ---


def extract_utp_sections(text: str) -> list[dict]:
    """Parse unit-test.md into structured test case sections."""
    utps = []
    headings = list(_UTP_HEADING.finditer(text))
    for i, m in enumerate(headings):
        start = m.start()
        end = headings[i + 1].start() if i + 1 < len(headings) else len(text)
        block = text[start:end]
        utp_id = m.group(1)
        description = m.group(2)

        technique_match = _TECHNIQUE_LINE.search(block)
        technique = technique_match.group(1).strip() if technique_match else ""

        uts_ids = _UTS_LINE.findall(block)
        has_mock_registry = bool(_MOCK_REGISTRY.search(block))

        utps.append({
            "id": utp_id,
            "description": description,
            "technique": technique,
            "uts_ids": uts_ids,
            "has_mock_registry": has_mock_registry,
        })
    return utps


def _mod_base_key(mod_id: str) -> str:
    """Strip 'MOD-' prefix. E.g. 'MOD-001' -> '001'."""
    return mod_id[4:]


def _utp_base_key(utp_id: str) -> str:
    """Strip 'UTP-' and trailing '-[A-Z]'. E.g. 'UTP-001-A' -> '001'."""
    without_prefix = utp_id[4:]
    return re.sub(r"-[A-Z]$", "", without_prefix)


def _utp_full_key(utp_id: str) -> str:
    """Strip 'UTP-' prefix. E.g. 'UTP-001-A' -> '001-A'."""
    return utp_id[4:]


def _uts_full_key(uts_id: str) -> str:
    """Strip 'UTS-' prefix. E.g. 'UTS-001-A1' -> '001-A1'."""
    return uts_id[4:]


def validate_mod_hierarchy(
    mod_ids: list[str], utp_ids: list[str], uts_ids: list[str]
) -> dict:
    """Validate hierarchical consistency between MOD, UTP, and UTS IDs."""
    mod_bases = {_mod_base_key(m) for m in mod_ids}
    utp_bases = {_utp_base_key(u) for u in utp_ids}
    utp_fulls = {_utp_full_key(u) for u in utp_ids}
    uts_fulls = {_uts_full_key(s) for s in uts_ids}

    orphaned_utps = [u for u in utp_ids if _utp_base_key(u) not in mod_bases]
    orphaned_uts = [
        s for s in uts_ids
        if not any(_uts_full_key(s).startswith(uf) for uf in utp_fulls)
    ]
    uncovered_mods = [m for m in mod_ids if _mod_base_key(m) not in utp_bases]
    utps_without_uts = [
        u for u in utp_ids
        if not any(sf.startswith(_utp_full_key(u)) for sf in uts_fulls)
    ]

    return {
        "orphaned_utps": orphaned_utps,
        "orphaned_uts": orphaned_uts,
        "uncovered_mods": uncovered_mods,
        "utps_without_uts": utps_without_uts,
    }


def validate_unit_test(
    test_text: str,
    mod_ids: list[str] | None = None,
    external_mod_ids: list[str] | None = None,
) -> dict:
    """Run all unit test validations.

    Args:
        test_text: Full text of unit-test.md.
        mod_ids: Optional list of MOD IDs from module-design.md (all modules).
        external_mod_ids: Optional list of [EXTERNAL] MOD IDs to exclude from coverage.
    """
    utps = extract_utp_sections(test_text)
    utp_ids = [u["id"] for u in utps]
    unique_utps = list(dict.fromkeys(utp_ids))

    all_uts = []
    for u in utps:
        all_uts.extend(u["uts_ids"])
    unique_uts = list(dict.fromkeys(all_uts))

    issues: list[str] = []
    scored_issue_count = 0

    # ID format validation
    for prefix, ids in [("UTP", unique_utps), ("UTS", unique_uts)]:
        bad = validate_id_format(ids, prefix)
        for b in bad:
            issues.append(f"Malformed {prefix} ID: {b}")
            scored_issue_count += 1

    # Duplicate check
    for prefix, ids in [("UTP", utp_ids), ("UTS", all_uts)]:
        dupes = find_duplicates(ids)
        for d in dupes:
            issues.append(f"Duplicate {prefix} ID: {d}")
            scored_issue_count += 1

    # Per-UTP structural checks
    invalid_techniques = []
    for utp in utps:
        if not utp["technique"]:
            issues.append(f"{utp['id']}: Missing Technique field")
            scored_issue_count += 1
        elif utp["technique"] not in VALID_TECHNIQUES:
            issues.append(f"{utp['id']}: Invalid technique '{utp['technique']}'")
            invalid_techniques.append(utp["technique"])
            scored_issue_count += 1

        if not utp["uts_ids"]:
            issues.append(f"{utp['id']}: No Unit Scenarios (UTS) found")
            scored_issue_count += 1

        if not utp["has_mock_registry"]:
            issues.append(f"{utp['id']}: Missing Dependency & Mock Registry")
            scored_issue_count += 1

    # Hierarchy: MOD → UTP → UTS
    testable_mods = mod_ids or []
    if external_mod_ids:
        testable_mods = [m for m in testable_mods if m not in set(external_mod_ids)]

    hierarchy = validate_mod_hierarchy(testable_mods, unique_utps, unique_uts)
    for u in hierarchy["orphaned_utps"]:
        issues.append(f"Orphaned UTP (no matching MOD): {u}")
        scored_issue_count += 1
    for s in hierarchy["orphaned_uts"]:
        issues.append(f"Orphaned UTS (no matching UTP): {s}")
        scored_issue_count += 1
    if testable_mods:
        for m in hierarchy["uncovered_mods"]:
            issues.append(f"Uncovered MOD (no UTP): {m}")
            scored_issue_count += 1
    for u in hierarchy["utps_without_uts"]:
        issues.append(f"UTP without UTS: {u}")
        scored_issue_count += 1

    # External bypass check
    external_bypassed = list(_EXTERNAL_BYPASS.finditer(test_text))

    # Technique distribution
    technique_counts: dict[str, int] = {}
    for utp in utps:
        t = utp["technique"]
        if t:
            technique_counts[t] = technique_counts.get(t, 0) + 1

    total_items = max(len(unique_utps) + len(unique_uts), 1)
    score = max(0.0, 1.0 - scored_issue_count / total_items)

    return {
        "score": round(score, 2),
        "issues": issues,
        "utp_ids": unique_utps,
        "uts_ids": unique_uts,
        "utps": utps,
        "hierarchy": hierarchy,
        "technique_counts": technique_counts,
        "invalid_techniques": invalid_techniques,
        "external_bypassed": len(external_bypassed),
    }
