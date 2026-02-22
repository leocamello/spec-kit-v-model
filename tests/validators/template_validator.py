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


def _is_table_format_requirements(text: str) -> bool:
    """Detect table-based requirements format (| ID | Description | ...)."""
    return bool(re.search(r"^\|\s*ID\s*\|", text, re.MULTILINE))


def validate_requirements(text: str) -> dict:
    """Validate a requirements.md document structure.

    Accepts three formats:
    - Template-style sections (Overview + Requirements)
    - Golden-fixture-style sections (Document Control + Requirements)
    - Table-based format (markdown table with ID | Description columns)
    """
    sections = _find_sections(text)
    section_names = [title for _, title in sections]
    issues = []

    is_table = _is_table_format_requirements(text)

    if is_table:
        # Table format: just need a heading and REQ entries in table rows
        if not sections:
            issues.append("Missing document title heading")
    else:
        # Check for a document-header section (either style is valid)
        if not (_section_exists(sections, "Overview") or _section_exists(sections, "Document Control")):
            issues.append("Missing 'Overview' or 'Document Control' section")

        if not _section_exists(sections, "Requirements"):
            issues.append("Missing 'Requirements' section")

    # Check for at least one REQ block
    req_pattern = re.compile(r"REQ-(?:[A-Z]+-)?[0-9]{3}")
    if not req_pattern.search(text):
        issues.append("No REQ-NNN blocks found")

    # Check heading hierarchy
    issues.extend(_check_heading_hierarchy(sections))

    total_checks = 4  # header, content section, REQ block, heading hierarchy
    failed = min(len(issues), total_checks)
    score = max(0.0, 1.0 - failed / total_checks)

    return {
        "score": round(score, 2),
        "issues": issues,
        "sections_found": section_names,
    }


def validate_acceptance_plan(text: str) -> dict:
    """Validate an acceptance-plan.md document structure.

    Accepts both template-style sections (Overview) and golden-fixture-style
    sections (Test Strategy) since LLM output may follow either convention.
    """
    sections = _find_sections(text)
    section_names = [title for _, title in sections]
    issues = []

    if not (_section_exists(sections, "Overview") or _section_exists(sections, "Test Strategy")):
        issues.append("Missing 'Overview' or 'Test Strategy' section")

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


def validate_system_design(text: str) -> dict:
    """Validate a system-design.md document structure."""
    sections = _find_sections(text)
    section_names = [title for _, title in sections]
    issues = []

    if not _section_exists(sections, "Decomposition"):
        issues.append("Missing 'Decomposition' section")

    if not _section_exists(sections, "Dependency"):
        issues.append("Missing 'Dependency' section")

    if not _section_exists(sections, "Interface"):
        issues.append("Missing 'Interface' section")

    sys_pattern = re.compile(r"SYS-[0-9]{3}")
    if not sys_pattern.search(text):
        issues.append("No SYS-NNN identifiers found")

    total_checks = 4
    failed = min(len(issues), total_checks)
    score = max(0.0, 1.0 - failed / total_checks)

    return {
        "score": round(score, 2),
        "issues": issues,
        "sections_found": section_names,
    }


def validate_system_test(text: str) -> dict:
    """Validate a system-test.md document structure."""
    sections = _find_sections(text)
    section_names = [title for _, title in sections]
    issues = []

    stp_pattern = re.compile(r"STP-[0-9]{3}-[A-Z]")
    if not stp_pattern.search(text):
        issues.append("No STP-NNN-X test case identifiers found")

    sts_pattern = re.compile(r"STS-[0-9]{3}-[A-Z][0-9]+")
    if not sts_pattern.search(text):
        issues.append("No STS-NNN-X# scenario identifiers found")

    if not _section_exists(sections, "Coverage"):
        issues.append("Missing 'Coverage' section")

    total_checks = 3
    failed = min(len(issues), total_checks)
    score = max(0.0, 1.0 - failed / total_checks)

    return {
        "score": round(score, 2),
        "issues": issues,
        "sections_found": section_names,
    }


def validate_architecture_design(text: str) -> dict:
    """Validate an architecture-design.md document structure."""
    sections = _find_sections(text)
    section_names = [title for _, title in sections]
    issues = []

    if not _section_exists(sections, "Logical"):
        issues.append("Missing 'Logical View' section")

    if not _section_exists(sections, "Process"):
        issues.append("Missing 'Process View' section")

    if not _section_exists(sections, "Interface"):
        issues.append("Missing 'Interface View' section")

    if not _section_exists(sections, "Data Flow"):
        issues.append("Missing 'Data Flow View' section")

    arch_pattern = re.compile(r"ARCH-[0-9]{3}")
    if not arch_pattern.search(text):
        issues.append("No ARCH-NNN identifiers found")

    if not _section_exists(sections, "Coverage"):
        issues.append("Missing 'Coverage' section")

    total_checks = 6
    failed = min(len(issues), total_checks)
    score = max(0.0, 1.0 - failed / total_checks)

    return {
        "score": round(score, 2),
        "issues": issues,
        "sections_found": section_names,
    }


def validate_integration_test(text: str) -> dict:
    """Validate an integration-test.md document structure."""
    sections = _find_sections(text)
    section_names = [title for _, title in sections]
    issues = []

    itp_pattern = re.compile(r"ITP-[0-9]{3}-[A-Z]")
    if not itp_pattern.search(text):
        issues.append("No ITP-NNN-X test case identifiers found")

    its_pattern = re.compile(r"ITS-[0-9]{3}-[A-Z][0-9]+")
    if not its_pattern.search(text):
        issues.append("No ITS-NNN-X# scenario identifiers found")

    if not _section_exists(sections, "Coverage"):
        issues.append("Missing 'Coverage' section")

    techniques = [
        "Interface Contract Testing",
        "Data Flow Testing",
        "Interface Fault Injection",
        "Concurrency",
    ]
    for technique in techniques:
        if technique.lower() not in text.lower():
            issues.append(f"Missing technique: '{technique}'")

    total_checks = 3 + len(techniques)
    failed = min(len(issues), total_checks)
    score = max(0.0, 1.0 - failed / total_checks)

    return {
        "score": round(score, 2),
        "issues": issues,
        "sections_found": section_names,
    }


def validate_module_design(text: str) -> dict:
    """Validate a module-design.md document structure."""
    sections = _find_sections(text)
    section_names = [title for _, title in sections]
    issues = []

    mod_pattern = re.compile(r"MOD-[0-9]{3}")
    if not mod_pattern.search(text):
        issues.append("No MOD-NNN identifiers found")

    module_heading = re.compile(r"### Module: MOD-[0-9]{3}")
    if not module_heading.search(text):
        issues.append("No '### Module: MOD-NNN' headings found")

    mod_views = [
        "Algorithmic",
        "State Machine",
        "Internal Data Structures",
        "Error Handling",
    ]
    for view in mod_views:
        if not _section_exists(sections, view):
            issues.append(f"Missing '{view}' section")

    pseudocode_block = re.compile(r"```pseudocode")
    if not pseudocode_block.search(text):
        issues.append("No ```pseudocode blocks found")

    if not _section_exists(sections, "Coverage"):
        issues.append("Missing 'Coverage Summary' section")

    total_checks = 8
    failed = min(len(issues), total_checks)
    score = max(0.0, 1.0 - failed / total_checks)

    return {
        "score": round(score, 2),
        "issues": issues,
        "sections_found": section_names,
    }


def validate_unit_test(text: str) -> dict:
    """Validate a unit-test.md document structure."""
    sections = _find_sections(text)
    section_names = [title for _, title in sections]
    issues = []

    utp_pattern = re.compile(r"UTP-[0-9]{3}-[A-Z]")
    if not utp_pattern.search(text):
        issues.append("No UTP-NNN-X test case identifiers found")

    uts_pattern = re.compile(r"UTS-[0-9]{3}-[A-Z][0-9]+")
    if not uts_pattern.search(text):
        issues.append("No UTS-NNN-X# scenario identifiers found")

    test_case_heading = re.compile(r"#### Test Case: UTP-[0-9]{3}-[A-Z]")
    if not test_case_heading.search(text):
        issues.append("No '#### Test Case: UTP-NNN-X' headings found")

    scenario_line = re.compile(r"\*\*Unit Scenario: UTS-[0-9]{3}-[A-Z][0-9]+\*\*")
    if not scenario_line.search(text):
        issues.append("No '**Unit Scenario: UTS-NNN-X#**' lines found")

    if not _section_exists(sections, "Coverage"):
        issues.append("Missing 'Coverage Summary' section")

    valid_techniques = [
        "Statement & Branch Coverage",
        "Boundary Value Analysis",
        "Equivalence Partitioning",
        "Strict Isolation",
        "State Transition Testing",
    ]
    has_technique = any(t.lower() in text.lower() for t in valid_techniques)
    if not has_technique:
        issues.append("No valid unit test techniques found")

    mock_registry = re.compile(r"\*\*Dependency & Mock Registry")
    if not mock_registry.search(text):
        issues.append("No Dependency & Mock Registry sections found")

    total_checks = 7
    failed = min(len(issues), total_checks)
    score = max(0.0, 1.0 - failed / total_checks)

    return {
        "score": round(score, 2),
        "issues": issues,
        "sections_found": section_names,
    }
