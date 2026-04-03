"""Structural validators for impact-analysis JSON output.

Validates the JSON structure produced by impact-analysis.sh / impact-analysis.ps1:
changed_ids, direction, suspect_artifacts, blast_radius, revalidation_order.
"""

import json
import re
from typing import Optional


# Valid V-Model ID pattern (same 13 prefixes as impact-analysis script)
VMODEL_ID_PATTERN = re.compile(
    r"^(REQ|ATP|SCN|SYS|STP|STS|ARCH|ITP|ITS|MOD|UTP|UTS|HAZ)"
    r"(-[A-Z]+)?-\d{3}(-[A-Z]\d?)?$"
)

VALID_DIRECTIONS = {"downward", "upward", "full"}

# V-Model levels in top-down order
LEVELS_TOP_DOWN = [
    "REQ", "ATP", "SCN", "SYS", "STP", "STS",
    "ARCH", "ITP", "ITS", "MOD", "UTP", "UTS", "HAZ",
]


def parse_json(text: str) -> tuple[Optional[dict], Optional[str]]:
    """Parse JSON text into dict; returns (data, None) or (None, error)."""
    try:
        data = json.loads(text)
        return data, None
    except json.JSONDecodeError as e:
        return None, f"Invalid JSON: {e}"


def validate_top_level_keys(data: dict) -> list[str]:
    """Check all required top-level keys are present."""
    required = {"changed_ids", "direction", "suspect_artifacts", "blast_radius", "revalidation_order"}
    missing = required - set(data.keys())
    return [f"Missing key: {k}" for k in sorted(missing)]


def validate_direction(data: dict) -> list[str]:
    """Check direction field is valid."""
    direction = data.get("direction", "")
    if direction not in VALID_DIRECTIONS:
        return [f"Invalid direction: '{direction}' (expected one of {VALID_DIRECTIONS})"]
    return []


def validate_changed_ids(data: dict) -> list[str]:
    """Check changed_ids is a non-empty list of valid V-Model IDs."""
    issues = []
    changed = data.get("changed_ids", [])
    if not isinstance(changed, list):
        return ["changed_ids is not a list"]
    if len(changed) == 0:
        return ["changed_ids is empty"]
    for cid in changed:
        if not VMODEL_ID_PATTERN.match(cid):
            issues.append(f"Invalid changed ID format: '{cid}'")
    return issues


def validate_suspect_artifacts(data: dict) -> list[str]:
    """Check suspect_artifacts structure and ID formats."""
    issues = []
    suspects = data.get("suspect_artifacts", {})
    if not isinstance(suspects, dict):
        return ["suspect_artifacts is not a dict"]

    direction = data.get("direction", "")
    if direction == "full":
        # Full mode has "downstream" and "upstream" sub-dicts
        for key in ("downstream", "upstream"):
            if key not in suspects:
                issues.append(f"Full mode missing '{key}' in suspect_artifacts")
            elif isinstance(suspects[key], dict):
                issues.extend(_validate_level_dict(suspects[key], f"suspect_artifacts.{key}"))
    else:
        issues.extend(_validate_level_dict(suspects, "suspect_artifacts"))

    return issues


def _validate_level_dict(level_dict: dict, prefix: str) -> list[str]:
    """Validate a dict of level → ID list."""
    issues = []
    for level, ids in level_dict.items():
        if level not in LEVELS_TOP_DOWN:
            issues.append(f"{prefix}: unknown level '{level}'")
        if not isinstance(ids, list):
            issues.append(f"{prefix}.{level}: not a list")
            continue
        for vid in ids:
            if not VMODEL_ID_PATTERN.match(vid):
                issues.append(f"{prefix}.{level}: invalid ID '{vid}'")
    return issues


def validate_blast_radius(data: dict) -> list[str]:
    """Check blast_radius structure and consistency."""
    issues = []
    br = data.get("blast_radius", {})
    if not isinstance(br, dict):
        return ["blast_radius is not a dict"]

    if "total" not in br:
        issues.append("blast_radius missing 'total'")
    if "by_level" not in br:
        issues.append("blast_radius missing 'by_level'")

    if "total" in br and "by_level" in br:
        by_level = br["by_level"]
        if isinstance(by_level, dict):
            computed_total = sum(by_level.values())
            if computed_total != br["total"]:
                issues.append(
                    f"blast_radius.total ({br['total']}) != "
                    f"sum of by_level ({computed_total})"
                )

    return issues


def validate_revalidation_order(data: dict) -> list[str]:
    """Check revalidation_order is a list of valid IDs matching suspects."""
    issues = []
    order = data.get("revalidation_order", [])
    if not isinstance(order, list):
        return ["revalidation_order is not a list"]

    # All IDs in order should be valid
    for vid in order:
        if not VMODEL_ID_PATTERN.match(vid):
            issues.append(f"revalidation_order: invalid ID '{vid}'")

    # Count should match blast radius total
    br = data.get("blast_radius", {})
    if isinstance(br, dict) and "total" in br:
        if len(order) != br["total"]:
            issues.append(
                f"revalidation_order length ({len(order)}) != "
                f"blast_radius.total ({br['total']})"
            )

    # No duplicates
    if len(order) != len(set(order)):
        issues.append("revalidation_order contains duplicates")

    return issues


def validate_no_self_reference(data: dict) -> list[str]:
    """Check changed IDs don't appear in suspect artifacts."""
    issues = []
    changed = set(data.get("changed_ids", []))
    suspects = data.get("suspect_artifacts", {})
    direction = data.get("direction", "")

    def _check_dict(d: dict) -> None:
        for _level, ids in d.items():
            if isinstance(ids, list):
                for vid in ids:
                    if vid in changed:
                        issues.append(f"Changed ID '{vid}' appears in suspects")

    if direction == "full":
        for sub in ("downstream", "upstream"):
            if sub in suspects and isinstance(suspects[sub], dict):
                _check_dict(suspects[sub])
    else:
        _check_dict(suspects)

    return issues


def validate_all(text: str) -> dict:
    """Run all structural validations on JSON output text.

    Returns:
        dict with keys: score (0.0-1.0), issues (list[str]),
        blast_total (int), direction (str), changed_count (int)
    """
    data, parse_err = parse_json(text)
    if parse_err:
        return {"score": 0.0, "issues": [parse_err], "blast_total": 0,
                "direction": "", "changed_count": 0}

    issues: list[str] = []
    total_checks = 0

    checks = [
        validate_top_level_keys,
        validate_direction,
        validate_changed_ids,
        validate_suspect_artifacts,
        validate_blast_radius,
        validate_revalidation_order,
        validate_no_self_reference,
    ]

    for check_fn in checks:
        total_checks += 1
        check_issues = check_fn(data)
        issues.extend(check_issues)

    score = round(max(0.0, 1.0 - len(issues) / max(total_checks, 1)), 2)

    return {
        "score": score,
        "issues": issues,
        "blast_total": data.get("blast_radius", {}).get("total", 0),
        "direction": data.get("direction", ""),
        "changed_count": len(data.get("changed_ids", [])),
    }
