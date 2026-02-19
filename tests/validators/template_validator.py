"""Deterministic structural validators for V-Model markdown document templates."""

import re


def _find_sections(text: str) -> list[tuple[int, str]]:
    """Return list of (level, title) for all markdown headings."""
    sections = []
    for match in re.finditer(r"^(#{1,6})\s+(.+)$", text, re.MULTILINE):
        level = len(match.group(1))
        title = match.group(2).strip()
        sections.append((level, title))
    return sections


def _check_heading_hierarchy(sections: list[tuple[int, str]]) -> list[str]:
    """Check that heading levels don't skip (e.g., h1 -> h3 without h2)."""
    issues = []
    prev_level = 0
    for level, title in sections:
        if prev_level > 0 and level > prev_level + 1:
            issues.append(
                f"Heading level skipped: '{title}' is h{level} after h{prev_level}"
            )
        prev_level = level
    return issues


def _section_exists(sections: list[tuple[int, str]], name: str) -> bool:
    """Check if a section with the given name exists (case-insensitive substring match)."""
    name_lower = name.lower()
    return any(name_lower in title.lower() for _, title in sections)


def validate_requirements(text: str) -> dict:
    """Validate a requirements.md document structure."""
    sections = _find_sections(text)
    section_names = [title for _, title in sections]
    issues = []

    # Check required sections
    if not _section_exists(sections, "Document Control"):
        issues.append("Missing 'Document Control' section")

    if not _section_exists(sections, "Summary"):
        issues.append("Missing 'Summary' section")

    # Check for at least one REQ block
    req_pattern = re.compile(r"REQ-(?:[A-Z]+-)?[0-9]{3}")
    if not req_pattern.search(text):
        issues.append("No REQ-NNN blocks found")

    # Check heading hierarchy
    issues.extend(_check_heading_hierarchy(sections))

    total_checks = 4  # Document Control, Summary, REQ block, heading hierarchy
    failed = min(len(issues), total_checks)
    score = max(0.0, 1.0 - failed / total_checks)

    return {
        "score": round(score, 2),
        "issues": issues,
        "sections_found": section_names,
    }


def validate_acceptance_plan(text: str) -> dict:
    """Validate an acceptance-plan.md document structure."""
    sections = _find_sections(text)
    section_names = [title for _, title in sections]
    issues = []

    if not _section_exists(sections, "Test Strategy"):
        issues.append("Missing 'Test Strategy' section")

    if not _section_exists(sections, "Requirement Validation"):
        issues.append("Missing 'Requirement Validation' block")

    atp_pattern = re.compile(r"ATP-(?:[A-Z]+-)?[0-9]{3}-[A-Z]")
    if not atp_pattern.search(text):
        issues.append("No ATP blocks found")

    scn_pattern = re.compile(r"SCN-(?:[A-Z]+-)?[0-9]{3}-[A-Z][0-9]+")
    if not scn_pattern.search(text):
        issues.append("No SCN blocks found")

    if not _section_exists(sections, "Coverage Summary"):
        issues.append("Missing 'Coverage Summary' section")

    total_checks = 5
    failed = min(len(issues), total_checks)
    score = max(0.0, 1.0 - failed / total_checks)

    return {
        "score": round(score, 2),
        "issues": issues,
        "sections_found": section_names,
    }


def validate_traceability_matrix(text: str) -> dict:
    """Validate a traceability-matrix.md document structure."""
    sections = _find_sections(text)
    section_names = [title for _, title in sections]
    issues = []

    if not _section_exists(sections, "Matrix"):
        issues.append("Missing 'Matrix' section")

    # Check for markdown table with required columns
    required_columns = ["Requirement ID", "Test Case ID", "Scenario ID", "Status"]
    table_header_pattern = re.compile(r"\|.*\|")
    table_match = table_header_pattern.search(text)
    if table_match:
        header_line = table_match.group(0)
        for col in required_columns:
            if col.lower() not in header_line.lower():
                issues.append(f"Missing required table column: '{col}'")
    else:
        issues.append("No markdown table found")

    if not _section_exists(sections, "Coverage Metrics"):
        issues.append("Missing 'Coverage Metrics' section")

    if not _section_exists(sections, "Gap Analysis"):
        issues.append("Missing 'Gap Analysis' section")

    total_checks = 4 + len(required_columns)
    failed = min(len(issues), total_checks)
    score = max(0.0, 1.0 - failed / total_checks)

    return {
        "score": round(score, 2),
        "issues": issues,
        "sections_found": section_names,
    }
