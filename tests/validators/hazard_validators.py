"""Structural validators for hazard-analysis.md (FMEA) documents.

Validates HAZ-NNN ID format, FMEA table structure, required sections,
operational state references, and mitigation traceability links.
"""

import re
from typing import Optional


# HAZ-NNN pattern: 3-digit zero-padded
HAZ_ID_PATTERN = re.compile(r"HAZ-(\d{3})")
HAZ_ID_STRICT = re.compile(r"^HAZ-\d{3}$")

# FMEA table row pattern (starts with | HAZ-NNN |)
FMEA_ROW_PATTERN = re.compile(
    r"^\|\s*(HAZ-\d{3})\s*\|"
    r"\s*(SYS-\d{3})\s*\|"      # Component
    r"\s*(.+?)\s*\|"             # Failure Mode
    r"\s*([A-Z_]+)\s*\|"         # Operational State
    r"\s*(.+?)\s*\|"             # Effect
    r"\s*(\w+)\s*\|"             # Severity
    r"\s*(\w+)\s*\|"             # Likelihood
    r"\s*(\w+)\s*\|"             # Risk Level
    r"\s*(.+?)\s*\|"             # Mitigation
    r"\s*(.+?)\s*\|",            # Residual Risk
    re.MULTILINE,
)

# Required sections in a hazard-analysis.md
REQUIRED_SECTIONS = [
    "Risk Matrix",
    "Operational States",
    "Hazard Register",
    "Coverage Summary",
]

VALID_SEVERITIES = {
    "Catastrophic", "Critical", "Serious", "Minor", "Negligible",
}

VALID_LIKELIHOODS = {
    "Frequent", "Probable", "Occasional", "Remote", "Improbable",
}

VALID_RISK_LEVELS = {
    "Unacceptable", "Undesirable", "Tolerable", "Acceptable",
}

# Mitigation reference patterns
MITIGATION_REF = re.compile(r"(REQ|SYS)-[A-Z]*-?\d{3}")


def extract_haz_ids(text: str) -> list[str]:
    """Extract all unique HAZ-NNN IDs from FMEA table rows."""
    ids = []
    for match in FMEA_ROW_PATTERN.finditer(text):
        haz_id = match.group(1)
        if haz_id not in ids:
            ids.append(haz_id)
    return ids


def extract_fmea_rows(text: str) -> list[dict]:
    """Extract all FMEA table rows as structured dicts."""
    rows = []
    for match in FMEA_ROW_PATTERN.finditer(text):
        rows.append({
            "haz_id": match.group(1),
            "component": match.group(2),
            "failure_mode": match.group(3).strip(),
            "operational_state": match.group(4).strip(),
            "effect": match.group(5).strip(),
            "severity": match.group(6).strip(),
            "likelihood": match.group(7).strip(),
            "risk_level": match.group(8).strip(),
            "mitigation": match.group(9).strip(),
            "residual_risk": match.group(10).strip(),
        })
    return rows


def validate_haz_id_format(ids: list[str]) -> list[str]:
    """Return list of IDs that don't match HAZ-NNN format."""
    return [i for i in ids if not HAZ_ID_STRICT.match(i)]


def validate_sequential_ids(ids: list[str]) -> list[str]:
    """Check IDs are sequential (no gaps in initial generation)."""
    issues = []
    numbers = sorted(int(HAZ_ID_PATTERN.match(i).group(1)) for i in ids if HAZ_ID_PATTERN.match(i))
    if numbers and numbers[0] != 1:
        issues.append(f"HAZ IDs do not start at 001 (starts at {numbers[0]:03d})")
    for i in range(1, len(numbers)):
        if numbers[i] != numbers[i - 1] + 1:
            issues.append(f"Gap between HAZ-{numbers[i-1]:03d} and HAZ-{numbers[i]:03d}")
    return issues


def validate_sections(text: str) -> list[str]:
    """Check all required sections are present."""
    issues = []
    text_lower = text.lower()
    for section in REQUIRED_SECTIONS:
        if section.lower() not in text_lower:
            issues.append(f"Missing required section: {section}")
    return issues


def validate_severities(rows: list[dict]) -> list[str]:
    """Check all severity values are from the standard scale."""
    issues = []
    for row in rows:
        if row["severity"] not in VALID_SEVERITIES:
            issues.append(f"{row['haz_id']}: invalid severity '{row['severity']}'")
    return issues


def validate_likelihoods(rows: list[dict]) -> list[str]:
    """Check all likelihood values are from the standard scale."""
    issues = []
    for row in rows:
        if row["likelihood"] not in VALID_LIKELIHOODS:
            issues.append(f"{row['haz_id']}: invalid likelihood '{row['likelihood']}'")
    return issues


def validate_risk_levels(rows: list[dict]) -> list[str]:
    """Check all risk level values are from the standard scale."""
    issues = []
    for row in rows:
        if row["risk_level"] not in VALID_RISK_LEVELS:
            issues.append(f"{row['haz_id']}: invalid risk level '{row['risk_level']}'")
    return issues


def validate_mitigation_refs(rows: list[dict]) -> list[str]:
    """Check every mitigation column references at least one REQ-NNN or SYS-NNN."""
    issues = []
    for row in rows:
        refs = MITIGATION_REF.findall(row["mitigation"])
        if not refs:
            issues.append(f"{row['haz_id']}: mitigation has no REQ/SYS reference")
    return issues


def validate_component_coverage(rows: list[dict], sys_ids: Optional[list[str]] = None) -> list[str]:
    """Check all SYS components referenced in rows; optionally check against provided list."""
    covered_sys = {row["component"] for row in rows}
    if sys_ids is None:
        return []
    issues = []
    for sys_id in sys_ids:
        if sys_id not in covered_sys:
            issues.append(f"{sys_id}: no hazard analysis coverage")
    return issues


def validate_all(text: str, system_design_text: Optional[str] = None) -> dict:
    """Run all structural validations and return a scored result.

    Returns:
        dict with keys: score (0.0-1.0), issues (list[str]), haz_count (int),
        row_count (int), sections_ok (bool)
    """
    issues: list[str] = []
    total_checks = 0

    # 1. Required sections
    section_issues = validate_sections(text)
    total_checks += len(REQUIRED_SECTIONS)
    issues.extend(section_issues)

    # 2. Extract and validate FMEA rows
    rows = extract_fmea_rows(text)
    haz_ids = extract_haz_ids(text)

    # 3. HAZ ID format
    total_checks += max(len(haz_ids), 1)
    bad_ids = validate_haz_id_format(haz_ids)
    for b in bad_ids:
        issues.append(f"Malformed HAZ ID: {b}")

    # 4. Sequential IDs
    total_checks += 1
    seq_issues = validate_sequential_ids(haz_ids)
    issues.extend(seq_issues)

    # 5. Severity, likelihood, risk level
    total_checks += len(rows) * 3
    issues.extend(validate_severities(rows))
    issues.extend(validate_likelihoods(rows))
    issues.extend(validate_risk_levels(rows))

    # 6. Mitigation references
    total_checks += len(rows)
    issues.extend(validate_mitigation_refs(rows))

    # 7. Component coverage (if system_design provided)
    if system_design_text:
        sys_pattern = re.compile(r"SYS-\d{3}")
        sys_ids = list(dict.fromkeys(sys_pattern.findall(system_design_text)))
        total_checks += len(sys_ids)
        issues.extend(validate_component_coverage(rows, sys_ids))

    score = round(max(0.0, 1.0 - len(issues) / total_checks), 2) if total_checks > 0 else 0.0

    return {
        "score": score,
        "issues": issues,
        "haz_count": len(haz_ids),
        "row_count": len(rows),
        "sections_ok": len(section_issues) == 0,
    }
