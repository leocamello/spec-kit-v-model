"""Deterministic structural validators for system-level V-Model ID formats and hierarchy."""

import re
from collections import Counter

# --- ID Patterns (inline match) ---

ID_PATTERNS = {
    "SYS": re.compile(r"SYS-[0-9]{3}"),
    "STP": re.compile(r"STP-[0-9]{3}-[A-Z]"),
    "STS": re.compile(r"STS-[0-9]{3}-[A-Z][0-9]+"),
}

# --- ID Patterns (strict full-match) ---

ID_STRICT_PATTERNS = {
    "SYS": re.compile(r"^SYS-[0-9]{3}$"),
    "STP": re.compile(r"^STP-[0-9]{3}-[A-Z]$"),
    "STS": re.compile(r"^STS-[0-9]{3}-[A-Z][0-9]+$"),
}

# --- Parent Requirements parsing ---

_PARENT_REQ_PATTERN = re.compile(r"REQ-(?:[A-Z]+-)?[0-9]{3}")


def extract_ids(text: str, prefix: str) -> list[str]:
    """Extract all IDs matching the given prefix (SYS, STP, STS) from text."""
    pattern = ID_PATTERNS.get(prefix)
    if pattern is None:
        raise ValueError(f"Unknown prefix: {prefix}. Must be one of: SYS, STP, STS")
    return pattern.findall(text)


def validate_id_format(ids: list[str], prefix: str) -> list[str]:
    """Return list of IDs that DON'T match the expected format. Empty = all valid."""
    pattern = ID_STRICT_PATTERNS.get(prefix)
    if pattern is None:
        raise ValueError(f"Unknown prefix: {prefix}. Must be one of: SYS, STP, STS")
    return [id_ for id_ in ids if not pattern.match(id_)]


def find_duplicates(ids: list[str]) -> list[str]:
    """Return list of IDs that appear more than once."""
    counts = Counter(ids)
    return [id_ for id_, count in counts.items() if count > 1]


def extract_parent_requirements(text: str, sys_id: str) -> list[str]:
    """Extract parent REQ-NNN references from a SYS component's row in a Markdown table."""
    sys_escaped = re.escape(sys_id)
    row_pattern = re.compile(
        rf"\|\s*{sys_escaped}\s*\|[^|]*\|[^|]*\|([^|]*)\|", re.MULTILINE
    )
    match = row_pattern.search(text)
    if not match:
        return []
    parent_cell = match.group(1)
    return _PARENT_REQ_PATTERN.findall(parent_cell)


def _sys_base_key(sys_id: str) -> str:
    """Strip 'SYS-' prefix. E.g. 'SYS-001' -> '001'."""
    return sys_id[4:]


def _stp_base_key(stp_id: str) -> str:
    """Strip 'STP-' and trailing '-[A-Z]'. E.g. 'STP-001-A' -> '001'."""
    without_prefix = stp_id[4:]
    return re.sub(r"-[A-Z]$", "", without_prefix)


def _stp_full_key(stp_id: str) -> str:
    """Strip 'STP-' prefix. E.g. 'STP-001-A' -> '001-A'."""
    return stp_id[4:]


def _sts_full_key(sts_id: str) -> str:
    """Strip 'STS-' prefix. E.g. 'STS-001-A1' -> '001-A1'."""
    return sts_id[4:]


def validate_hierarchy(sys_ids: list[str], stp_ids: list[str], sts_ids: list[str]) -> dict:
    """Validate hierarchical consistency between SYS, STP, and STS IDs."""
    sys_bases = {_sys_base_key(s) for s in sys_ids}
    stp_bases = {_stp_base_key(t) for t in stp_ids}
    stp_fulls = {_stp_full_key(t) for t in stp_ids}
    sts_fulls = {_sts_full_key(s) for s in sts_ids}

    orphaned_stps = [t for t in stp_ids if _stp_base_key(t) not in sys_bases]
    orphaned_stss = [
        s for s in sts_ids
        if not any(_sts_full_key(s).startswith(tf) for tf in stp_fulls)
    ]
    uncovered_sys = [s for s in sys_ids if _sys_base_key(s) not in stp_bases]
    stps_without_sts = [
        t for t in stp_ids
        if not any(sf.startswith(_stp_full_key(t)) for sf in sts_fulls)
    ]

    return {
        "orphaned_stps": orphaned_stps,
        "orphaned_stss": orphaned_stss,
        "uncovered_sys": uncovered_sys,
        "stps_without_sts": stps_without_sts,
    }


def validate_req_to_sys_coverage(
    req_ids: list[str], sys_ids: list[str], design_text: str
) -> dict:
    """Validate forward coverage: every REQ must appear as a parent in at least one SYS."""
    covered_reqs: set[str] = set()
    for sys_id in sys_ids:
        parents = extract_parent_requirements(design_text, sys_id)
        covered_reqs.update(parents)

    uncovered = [r for r in req_ids if r not in covered_reqs]
    orphaned_parents: list[str] = []
    req_set = set(req_ids)
    for sys_id in sys_ids:
        parents = extract_parent_requirements(design_text, sys_id)
        for p in parents:
            if p not in req_set:
                orphaned_parents.append(f"{sys_id} references unknown {p}")

    total = len(req_ids)
    covered = total - len(uncovered)
    coverage = (covered / total * 100) if total > 0 else 0.0

    return {
        "total_reqs": total,
        "covered_reqs": covered,
        "coverage_pct": round(coverage, 1),
        "uncovered_reqs": uncovered,
        "orphaned_parent_refs": orphaned_parents,
    }


def validate_all(design_text: str, test_text: str, req_ids: list[str] | None = None) -> dict:
    """Run all system-level validations on design + test documents."""
    sys_ids = extract_ids(design_text, "SYS")
    stp_ids = extract_ids(test_text, "STP")
    sts_ids = extract_ids(test_text, "STS")

    unique_sys = list(dict.fromkeys(sys_ids))
    unique_stp = list(dict.fromkeys(stp_ids))
    unique_sts = list(dict.fromkeys(sts_ids))

    issues: list[str] = []
    scored_issue_count = 0

    # Format validation
    for prefix, ids in [("SYS", unique_sys), ("STP", unique_stp), ("STS", unique_sts)]:
        bad = validate_id_format(ids, prefix)
        for b in bad:
            issues.append(f"Malformed {prefix} ID: {b}")
            scored_issue_count += 1

    # Hierarchy checks (SYS → STP → STS)
    hierarchy = validate_hierarchy(unique_sys, unique_stp, unique_sts)
    for t in hierarchy["orphaned_stps"]:
        issues.append(f"Orphaned STP (no matching SYS): {t}")
        scored_issue_count += 1
    for s in hierarchy["orphaned_stss"]:
        issues.append(f"Orphaned STS (no matching STP): {s}")
        scored_issue_count += 1
    for s in hierarchy["uncovered_sys"]:
        issues.append(f"Uncovered SYS (no STP): {s}")
        scored_issue_count += 1
    for t in hierarchy["stps_without_sts"]:
        issues.append(f"STP without STS: {t}")
        scored_issue_count += 1

    # Forward coverage (REQ → SYS) if req_ids provided
    req_coverage = None
    if req_ids:
        req_coverage = validate_req_to_sys_coverage(
            req_ids, unique_sys, design_text
        )
        for r in req_coverage["uncovered_reqs"]:
            issues.append(f"Uncovered REQ (no SYS): {r}")
            scored_issue_count += 1
        for o in req_coverage["orphaned_parent_refs"]:
            issues.append(f"Orphaned parent reference: {o}")
            scored_issue_count += 1

    total_items = len(unique_sys) + len(unique_stp) + len(unique_sts)
    if total_items == 0:
        score = 0.0
    else:
        score = max(0.0, 1.0 - scored_issue_count / total_items)

    return {
        "score": round(score, 2),
        "issues": issues,
        "sys_ids": unique_sys,
        "stp_ids": unique_stp,
        "sts_ids": unique_sts,
        "hierarchy": hierarchy,
        "req_coverage": req_coverage,
    }
