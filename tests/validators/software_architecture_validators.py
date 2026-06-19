"""Deterministic structural validators for software architecture-level V-Model artifacts.

Software architecture design (Path B) replaces system-design + architecture-design
with a single artifact. ARCH-NNN entries trace directly to REQ-NNN (no SYS
intermediate layer), following IEEE 42010 viewpoint framework with four views:
Logical, Process, Interface, and Data Flow.
"""

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

# --- Parent Requirements parsing (Path B — no SYS layer) ---

_PARENT_REQ_PATTERN = re.compile(r"REQ-(?:[A-Z]+-)?[0-9]{3}")
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


def extract_parent_requirements(text: str, arch_id: str) -> list[str]:
    """Extract parent REQ-NNN references from an ARCH module's row in the Logical View.

    In Path B (software architecture design), ARCH modules trace directly to
    REQ-NNN without an intermediate SYS layer.
    """
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
    return _PARENT_REQ_PATTERN.findall(parent_cell)


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
    in_mermaid_block = False
    mermaid_lines = []
    for line in text.split("\n"):
        if line.strip().startswith("```mermaid"):
            in_mermaid_block = True
            mermaid_lines = []
        elif line.strip().startswith("```") and in_mermaid_block:
            in_mermaid_block = False
            if not mermaid_lines:
                issues.append("Empty Mermaid code block")
        elif in_mermaid_block:
            mermaid_lines.append(line)

    # Check for unclosed mermaid blocks
    if in_mermaid_block:
        issues.append("Unclosed Mermaid code block")

    return issues


def validate_all(text: str) -> dict:
    """Run all software architecture design validators and return a score dict.

    Returns:
        dict with keys: score (float), issues (list of str),
        total_checks (int), failed_checks (int)
    """
    issues: list[str] = []
    total_checks = 0
    failed_checks = 0

    # 1. ARCH-NNN ID format
    arch_ids = extract_ids(text, "ARCH")
    unique_arch = list(dict.fromkeys(arch_ids))
    total_checks += max(len(unique_arch), 1)
    bad = validate_id_format(unique_arch, "ARCH")
    for b in bad:
        issues.append(f"Malformed ARCH ID: {b}")
        failed_checks += 1

    # 2. IEEE 42010 views presence
    missing_views = validate_views_present(text)
    total_checks += len(REQUIRED_VIEWS)
    for view in missing_views:
        issues.append(f"Missing IEEE 42010 view: {view}")
        failed_checks += 1

    # 3. Parent REQ references in every ARCH row (no SYS layer in Path B)
    for arch_id in unique_arch:
        total_checks += 1
        parents = extract_parent_requirements(text, arch_id)
        if not parents:
            issues.append(f"{arch_id} has no parent REQ reference")
            failed_checks += 1

    # 4. Mermaid syntax check
    mermaid_issues = validate_mermaid_syntax(text)
    total_checks += max(len(mermaid_issues), 1)
    for mi in mermaid_issues:
        issues.append(mi)
        failed_checks += 1

    score = round(
        max(0.0, 1.0 - failed_checks / total_checks) if total_checks > 0 else 0.0,
        2,
    )
    return {
        "score": score,
        "issues": issues,
        "total_checks": total_checks,
        "failed_checks": failed_checks,
    }
