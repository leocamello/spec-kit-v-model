"""Deterministic structural validators for BDD scenarios in V-Model markdown."""

import re

_SCN_HEADER = re.compile(
    r"\*\*(?:User\s+)?Scenario:\s*(SCN-(?:[A-Z]+-)?[0-9]{3}-[A-Z][0-9]+)\*\*"
)
_STEP_PATTERN = re.compile(
    r"^\s*\*\s*\*\*(Given|When|Then|And|But)\*\*\s+(.+)$", re.MULTILINE
)


def extract_scenarios(text: str) -> list[dict]:
    """Extract all BDD scenarios from text."""
    scenario_starts = list(_SCN_HEADER.finditer(text))
    scenarios = []

    for i, match in enumerate(scenario_starts):
        scn_id = match.group(1)
        start = match.end()
        end = scenario_starts[i + 1].start() if i + 1 < len(scenario_starts) else len(text)
        block = text[start:end]

        givens: list[str] = []
        whens: list[str] = []
        thens: list[str] = []
        ands: list[dict] = []

        last_type = None
        for step_match in _STEP_PATTERN.finditer(block):
            keyword = step_match.group(1)
            step_text = step_match.group(2).strip()

            if keyword == "Given":
                givens.append(step_text)
                last_type = "Given"
            elif keyword == "When":
                whens.append(step_text)
                last_type = "When"
            elif keyword == "Then":
                thens.append(step_text)
                last_type = "Then"
            elif keyword in ("And", "But"):
                parent = last_type or "Unknown"
                ands.append({"step": step_text, "parent": parent})
                # And/But inherits from parent, also add to parent list
                if parent == "Given":
                    givens.append(step_text)
                elif parent == "When":
                    whens.append(step_text)
                elif parent == "Then":
                    thens.append(step_text)

        scenarios.append({
            "id": scn_id,
            "givens": givens,
            "whens": whens,
            "thens": thens,
            "ands": ands,
        })

    return scenarios


def validate_scenario(scenario: dict) -> dict:
    """Validate a single BDD scenario."""
    issues = []
    scn_id = scenario.get("id", "unknown")

    if not scenario.get("givens"):
        issues.append(f"{scn_id}: Missing 'Given' step")
    if not scenario.get("whens"):
        issues.append(f"{scn_id}: Missing 'When' step")
    if not scenario.get("thens"):
        issues.append(f"{scn_id}: Missing 'Then' step")

    return {
        "valid": len(issues) == 0,
        "issues": issues,
    }


def validate_all_scenarios(text: str) -> dict:
    """Validate all BDD scenarios in text."""
    scenarios = extract_scenarios(text)
    all_issues = []
    valid_count = 0

    for scenario in scenarios:
        result = validate_scenario(scenario)
        if result["valid"]:
            valid_count += 1
        else:
            all_issues.extend(result["issues"])

    total = len(scenarios)
    score = (valid_count / total) if total > 0 else 0.0

    return {
        "score": round(score, 2),
        "total_scenarios": total,
        "valid_scenarios": valid_count,
        "issues": all_issues,
    }
