"""Deterministic structural validators for V-Model ID formats and hierarchy."""

import re
from collections import Counter

ID_PATTERNS = {
    "REQ": re.compile(r"REQ-(?:[A-Z]+-)?[0-9]{3}"),
    "ATP": re.compile(r"ATP-(?:[A-Z]+-)?[0-9]{3}-[A-Z]"),
    "SCN": re.compile(r"SCN-(?:[A-Z]+-)?[0-9]{3}-[A-Z][0-9]+"),
    "ARCH": re.compile(r"ARCH-[0-9]{3}"),
    "ITP": re.compile(r"ITP-[0-9]{3}-[A-Z]"),
    "ITS": re.compile(r"ITS-[0-9]{3}-[A-Z][0-9]+"),
    "MOD": re.compile(r"MOD-[0-9]{3}"),
    "UTP": re.compile(r"UTP-[0-9]{3}-[A-Z]"),
    "UTS": re.compile(r"UTS-[0-9]{3}-[A-Z][0-9]+"),
}

ID_STRICT_PATTERNS = {
    "REQ": re.compile(r"^REQ-(?:[A-Z]+-)?[0-9]{3}$"),
    "ATP": re.compile(r"^ATP-(?:[A-Z]+-)?[0-9]{3}-[A-Z]$"),
    "SCN": re.compile(r"^SCN-(?:[A-Z]+-)?[0-9]{3}-[A-Z][0-9]+$"),
    "ARCH": re.compile(r"^ARCH-[0-9]{3}$"),
    "ITP": re.compile(r"^ITP-[0-9]{3}-[A-Z]$"),
    "ITS": re.compile(r"^ITS-[0-9]{3}-[A-Z][0-9]+$"),
    "MOD": re.compile(r"^MOD-[0-9]{3}$"),
    "UTP": re.compile(r"^UTP-[0-9]{3}-[A-Z]$"),
    "UTS": re.compile(r"^UTS-[0-9]{3}-[A-Z][0-9]+$"),
}


def extract_ids(text: str, prefix: str) -> list[str]:
    """Extract all IDs matching the given prefix (REQ, ATP, SCN, ARCH, ITP, ITS) from text."""
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


def _req_base_key(req_id: str) -> str:
    """Strip 'REQ-' prefix. E.g. 'REQ-001' -> '001', 'REQ-NF-001' -> 'NF-001'."""
    return req_id[4:]


def _atp_base_key(atp_id: str) -> str:
    """Strip 'ATP-' and trailing '-[A-Z]'. E.g. 'ATP-001-A' -> '001', 'ATP-NF-001-B' -> 'NF-001'."""
    without_prefix = atp_id[4:]
    return re.sub(r"-[A-Z]$", "", without_prefix)


def _atp_full_key(atp_id: str) -> str:
    """Strip 'ATP-' prefix. E.g. 'ATP-001-A' -> '001-A', 'ATP-NF-001-A' -> 'NF-001-A'."""
    return atp_id[4:]


def _scn_full_key(scn_id: str) -> str:
    """Strip 'SCN-' prefix. E.g. 'SCN-001-A1' -> '001-A1'."""
    return scn_id[4:]


def validate_hierarchy(req_ids: list[str], atp_ids: list[str], scn_ids: list[str]) -> dict:
    """Validate hierarchical consistency between REQ, ATP, and SCN IDs."""
    req_bases = {_req_base_key(r) for r in req_ids}
    atp_bases = {_atp_base_key(a) for a in atp_ids}
    atp_fulls = {_atp_full_key(a) for a in atp_ids}
    scn_fulls = {_scn_full_key(s) for s in scn_ids}

    orphaned_atps = [a for a in atp_ids if _atp_base_key(a) not in req_bases]
    orphaned_scns = [
        s for s in scn_ids
        if not any(_scn_full_key(s).startswith(af) for af in atp_fulls)
    ]
    uncovered_reqs = [r for r in req_ids if _req_base_key(r) not in atp_bases]
    atps_without_scn = [
        a for a in atp_ids
        if not any(sf.startswith(_atp_full_key(a)) for sf in scn_fulls)
    ]

    return {
        "orphaned_atps": orphaned_atps,
        "orphaned_scns": orphaned_scns,
        "uncovered_reqs": uncovered_reqs,
        "atps_without_scn": atps_without_scn,
    }


def validate_all(text: str) -> dict:
    """Run all validations on a combined text (requirements + acceptance plan)."""
    req_ids = extract_ids(text, "REQ")
    atp_ids = extract_ids(text, "ATP")
    scn_ids = extract_ids(text, "SCN")

    issues = []
    unique_reqs = list(dict.fromkeys(req_ids))
    unique_atps = list(dict.fromkeys(atp_ids))
    unique_scns = list(dict.fromkeys(scn_ids))

    # Format validation (scored)
    scored_issue_count = 0
    for prefix, ids in [("REQ", unique_reqs), ("ATP", unique_atps), ("SCN", unique_scns)]:
        bad = validate_id_format(ids, prefix)
        for b in bad:
            issues.append(f"Malformed {prefix} ID: {b}")
            scored_issue_count += 1

    # Hierarchy checks (scored)
    hierarchy = validate_hierarchy(unique_reqs, unique_atps, unique_scns)
    for a in hierarchy["orphaned_atps"]:
        issues.append(f"Orphaned ATP (no matching REQ): {a}")
        scored_issue_count += 1
    for s in hierarchy["orphaned_scns"]:
        issues.append(f"Orphaned SCN (no matching ATP): {s}")
        scored_issue_count += 1
    for r in hierarchy["uncovered_reqs"]:
        issues.append(f"Uncovered REQ (no ATP): {r}")
        scored_issue_count += 1
    for a in hierarchy["atps_without_scn"]:
        issues.append(f"ATP without SCN: {a}")
        scored_issue_count += 1

    # Scoring based on format + hierarchy issues only
    total_items = len(unique_reqs) + len(unique_atps) + len(unique_scns)
    if total_items == 0:
        score = 0.0
    else:
        score = max(0.0, 1.0 - scored_issue_count / total_items)

    return {
        "score": round(score, 2),
        "issues": issues,
        "req_ids": unique_reqs,
        "atp_ids": unique_atps,
        "scn_ids": unique_scns,
        "hierarchy": hierarchy,
    }


# ---- Architecture-level helpers (v0.3.0) ----

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


def validate_arch_hierarchy(arch_ids: list[str], itp_ids: list[str], its_ids: list[str]) -> dict:
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


# ---- Module-level helpers (v0.4.0) ----

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


def validate_mod_hierarchy(mod_ids: list[str], utp_ids: list[str], uts_ids: list[str]) -> dict:
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
