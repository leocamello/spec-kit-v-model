"""Deterministic structural validators for architecture-level V-Model artifacts."""

import re
from collections import Counter

# --- ID Patterns (inline match) ---

ID_PATTERNS = {
    "ARCH": re.compile(r"ARCH-[0-9]{3}"),
    "ITP": re.compile(r"ITP-[0-9]{3}-[A-Z]"),
    "ITS": re.compile(r"ITS-[0-9]{3}-[A-Z][0-9]+"),
}

# --- ID Patterns (strict full-match) ---

ID_STRICT_PATTERNS = {
    "ARCH": re.compile(r"^ARCH-[0-9]{3}$"),
    "ITP": re.compile(r"^ITP-[0-9]{3}-[A-Z]$"),
    "ITS": re.compile(r"^ITS-[0-9]{3}-[A-Z][0-9]+$"),
}

# --- Parent System Components parsing ---

_PARENT_SYS_PATTERN = re.compile(r"SYS-[0-9]{3}")
_CROSS_CUTTING_PATTERN = re.compile(r"\[CROSS-CUTTING\]")

# --- Architecture view section headers ---

REQUIRED_VIEWS = [
    "Logical View",
    "Process View",
    "Interface View",
    "Data Flow View",
]

REQUIRED_TECHNIQUES = [
    "Interface Contract Testing",
    "Data Flow Testing",
    "Interface Fault Injection",
    "Concurrency & Race Condition Testing",
]


def extract_ids(text: str, prefix: str) -> list[str]:
    """Extract all IDs matching the given prefix (ARCH, ITP, ITS) from text."""
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


def extract_parent_system_components(text: str, arch_id: str) -> list[str]:
    """Extract parent SYS-NNN references from an ARCH module's row in the Logical View."""
    arch_escaped = re.escape(arch_id)
    row_pattern = re.compile(
        rf"\|\s*{arch_escaped}\s*\|[^|]*\|[^|]*\|([^|]*)\|", re.MULTILINE
    )
    match = row_pattern.search(text)
    if not match:
        return []
    parent_cell = match.group(1)
    if _CROSS_CUTTING_PATTERN.search(parent_cell):
        return ["CROSS-CUTTING"]
    return _PARENT_SYS_PATTERN.findall(parent_cell)


def validate_views_present(text: str) -> list[str]:
    """Return list of missing architecture views. Empty = all present."""
    missing = []
    for view in REQUIRED_VIEWS:
        if view not in text:
            missing.append(view)
    return missing


def validate_techniques_present(text: str) -> list[str]:
    """Return list of missing integration test techniques. Empty = all present."""
    missing = []
    for technique in REQUIRED_TECHNIQUES:
        if technique not in text:
            missing.append(technique)
    return missing


def validate_mermaid_syntax(text: str) -> list[str]:
    """Basic validation of Mermaid diagram syntax. Returns list of issues."""
    issues = []
    mermaid_blocks = re.findall(r"```mermaid\s*\n(.*?)```", text, re.DOTALL)
    if not mermaid_blocks:
        issues.append("No Mermaid diagrams found in Process View")
        return issues
    for i, block in enumerate(mermaid_blocks, 1):
        block = block.strip()
        if not block:
            issues.append(f"Mermaid block {i}: empty diagram")
            continue
        # Check for diagram type declaration
        first_line = block.split("\n")[0].strip()
        valid_types = ["sequenceDiagram", "graph", "flowchart", "classDiagram", "stateDiagram"]
        if not any(first_line.startswith(t) for t in valid_types):
            issues.append(f"Mermaid block {i}: missing or invalid diagram type '{first_line}'")
        # Check balanced participants in sequence diagrams
        if first_line == "sequenceDiagram":
            lines = block.split("\n")[1:]
            for line in lines:
                line = line.strip()
                if not line or line.startswith("%%"):
                    continue
                # Basic syntax: participant, arrows, notes, loops, alt, end
                valid_starts = [
                    "participant", "actor", "->>", "-->", "->", "-->>",
                    "Note", "loop", "alt", "else", "end", "rect", "opt",
                    "par", "and", "critical", "break", "activate", "deactivate",
                ]
                # Lines with arrows contain participant names before the arrow
                if any(arrow in line for arrow in ["->>", "-->>", "->", "-->"]):
                    continue
                if not any(line.startswith(s) for s in valid_starts):
                    continue  # Allow unknown lines (Mermaid is extensible)
    return issues


def _arch_base_key(arch_id: str) -> str:
    """Strip 'ARCH-' prefix. E.g. 'ARCH-001' -> '001'."""
    return arch_id[5:]


def _itp_base_key(itp_id: str) -> str:
    """Strip 'ITP-' and trailing '-[A-Z]'. E.g. 'ITP-001-A' -> '001'."""
    without_prefix = itp_id[4:]
    return re.sub(r"-[A-Z]$", "", without_prefix)


def _itp_full_key(itp_id: str) -> str:
    """Strip 'ITP-' prefix. E.g. 'ITP-001-A' -> '001-A'."""
    return itp_id[4:]


def _its_full_key(its_id: str) -> str:
    """Strip 'ITS-' prefix. E.g. 'ITS-001-A1' -> '001-A1'."""
    return its_id[4:]


def validate_hierarchy(arch_ids: list[str], itp_ids: list[str], its_ids: list[str]) -> dict:
    """Validate hierarchical consistency between ARCH, ITP, and ITS IDs."""
    arch_bases = {_arch_base_key(a) for a in arch_ids}
    itp_bases = {_itp_base_key(i) for i in itp_ids}
    itp_fulls = {_itp_full_key(i) for i in itp_ids}
    its_fulls = {_its_full_key(s) for s in its_ids}

    orphaned_itps = [i for i in itp_ids if _itp_base_key(i) not in arch_bases]
    orphaned_its = [
        s for s in its_ids
        if not any(_its_full_key(s).startswith(tf) for tf in itp_fulls)
    ]
    uncovered_archs = [a for a in arch_ids if _arch_base_key(a) not in itp_bases]
    itps_without_its = [
        i for i in itp_ids
        if not any(sf.startswith(_itp_full_key(i)) for sf in its_fulls)
    ]

    return {
        "orphaned_itps": orphaned_itps,
        "orphaned_its": orphaned_its,
        "uncovered_archs": uncovered_archs,
        "itps_without_its": itps_without_its,
    }


def validate_sys_to_arch_coverage(
    sys_ids: list[str], arch_ids: list[str], design_text: str
) -> dict:
    """Validate forward coverage: every SYS must appear as a parent in at least one ARCH."""
    covered_sys: set[str] = set()
    cross_cutting_count = 0
    for arch_id in arch_ids:
        parents = extract_parent_system_components(design_text, arch_id)
        if parents == ["CROSS-CUTTING"]:
            cross_cutting_count += 1
        else:
            covered_sys.update(parents)

    uncovered = [s for s in sys_ids if s not in covered_sys]
    total = len(sys_ids)
    covered = total - len(uncovered)
    coverage = (covered / total * 100) if total > 0 else 0.0

    return {
        "total_sys": total,
        "covered_sys": covered,
        "coverage_pct": round(coverage, 1),
        "uncovered_sys": uncovered,
        "cross_cutting_count": cross_cutting_count,
    }


def validate_architecture_design(design_text: str, sys_ids: list[str] | None = None) -> dict:
    """Run all architecture design validations."""
    arch_ids = list(dict.fromkeys(extract_ids(design_text, "ARCH")))

    issues: list[str] = []
    scored_issue_count = 0

    # Format validation
    bad = validate_id_format(arch_ids, "ARCH")
    for b in bad:
        issues.append(f"Malformed ARCH ID: {b}")
        scored_issue_count += 1

    # View completeness
    missing_views = validate_views_present(design_text)
    for v in missing_views:
        issues.append(f"Missing architecture view: {v}")
        scored_issue_count += 1

    # Mermaid syntax
    mermaid_issues = validate_mermaid_syntax(design_text)
    for m in mermaid_issues:
        issues.append(f"Mermaid: {m}")
        scored_issue_count += 1

    # SYS→ARCH coverage
    sys_coverage = None
    if sys_ids:
        sys_coverage = validate_sys_to_arch_coverage(sys_ids, arch_ids, design_text)
        for s in sys_coverage["uncovered_sys"]:
            issues.append(f"Uncovered SYS (no ARCH): {s}")
            scored_issue_count += 1

    total_items = len(arch_ids) + len(REQUIRED_VIEWS)
    score = max(0.0, 1.0 - scored_issue_count / total_items) if total_items > 0 else 0.0

    return {
        "score": round(score, 2),
        "issues": issues,
        "arch_ids": arch_ids,
        "missing_views": missing_views,
        "mermaid_issues": mermaid_issues,
        "sys_coverage": sys_coverage,
    }


def validate_integration_test(test_text: str, arch_ids: list[str] | None = None) -> dict:
    """Run all integration test validations."""
    itp_ids = list(dict.fromkeys(extract_ids(test_text, "ITP")))
    its_ids = list(dict.fromkeys(extract_ids(test_text, "ITS")))

    issues: list[str] = []
    scored_issue_count = 0

    # Format validation
    for prefix, ids in [("ITP", itp_ids), ("ITS", its_ids)]:
        bad = validate_id_format(ids, prefix)
        for b in bad:
            issues.append(f"Malformed {prefix} ID: {b}")
            scored_issue_count += 1

    # Technique presence
    missing_techniques = validate_techniques_present(test_text)
    for t in missing_techniques:
        issues.append(f"Missing integration test technique: {t}")
        scored_issue_count += 1

    # Hierarchy
    hierarchy = validate_hierarchy(arch_ids or [], itp_ids, its_ids)
    for i in hierarchy["orphaned_itps"]:
        issues.append(f"Orphaned ITP (no matching ARCH): {i}")
        scored_issue_count += 1
    for s in hierarchy["orphaned_its"]:
        issues.append(f"Orphaned ITS (no matching ITP): {s}")
        scored_issue_count += 1
    if arch_ids:
        for a in hierarchy["uncovered_archs"]:
            issues.append(f"Uncovered ARCH (no ITP): {a}")
            scored_issue_count += 1
    for i in hierarchy["itps_without_its"]:
        issues.append(f"ITP without ITS: {i}")
        scored_issue_count += 1

    total_items = len(itp_ids) + len(its_ids) + len(REQUIRED_TECHNIQUES)
    score = max(0.0, 1.0 - scored_issue_count / total_items) if total_items > 0 else 0.0

    return {
        "score": round(score, 2),
        "issues": issues,
        "itp_ids": itp_ids,
        "its_ids": its_ids,
        "missing_techniques": missing_techniques,
        "hierarchy": hierarchy,
    }
