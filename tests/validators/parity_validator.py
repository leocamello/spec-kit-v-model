#!/usr/bin/env python3
"""Cross-script parity validator for Bash/PowerShell impact-analysis.

Runs each (fixture, direction, IDs) combination through both impact-analysis.sh
and impact-analysis.ps1, parses JSON output, and asserts identical results.

Usage:
    python3 parity_validator.py <project_root>

Exit codes:
    0 — all combos match
    1 — at least one mismatch or script failure
"""

import json
import os
import subprocess
import sys


# Every (fixture_set, direction, id, vmodel_path_relative) combo to test.
# vmodel_path_relative is relative to project_root.
COMBOS = [
    # minimal (lives at tests/fixtures/minimal)
    ("minimal", "downward", "REQ-001", "tests/fixtures/minimal"),
    ("minimal", "upward", "MOD-001", "tests/fixtures/minimal"),
    ("minimal", "full", "SYS-001", "tests/fixtures/minimal"),
    # complex
    ("complex", "downward", "REQ-001", "tests/fixtures/complex"),
    ("complex", "upward", "MOD-006", "tests/fixtures/complex"),
    ("complex", "full", "SYS-003", "tests/fixtures/complex"),
    # linear
    ("linear", "downward", "REQ-001", "tests/fixtures/impact/linear"),
    ("linear", "upward", "MOD-001", "tests/fixtures/impact/linear"),
    ("linear", "full", "SYS-001", "tests/fixtures/impact/linear"),
    # diamond
    ("diamond", "downward", "REQ-001", "tests/fixtures/impact/diamond"),
    ("diamond", "upward", "MOD-002", "tests/fixtures/impact/diamond"),
    ("diamond", "full", "ARCH-004", "tests/fixtures/impact/diamond"),
    # disconnected
    ("disconnected", "downward", "REQ-001", "tests/fixtures/impact/disconnected"),
    ("disconnected", "downward", "REQ-002", "tests/fixtures/impact/disconnected"),
    ("disconnected", "upward", "MOD-001", "tests/fixtures/impact/disconnected"),
    # gaps
    ("gaps", "downward", "REQ-001", "tests/fixtures/gaps"),
    ("gaps", "upward", "MOD-001", "tests/fixtures/gaps"),
]


def normalize(obj):
    """Recursively normalize JSON for comparison.

    - Dicts: sorted by key
    - Lists of strings: sorted (ID lists are unordered sets)
    - Lists named 'revalidation_order': kept in order (order matters)
    - Everything else: pass-through
    """
    if isinstance(obj, dict):
        return {k: normalize(v) for k, v in sorted(obj.items())}
    if isinstance(obj, list):
        if all(isinstance(x, str) for x in obj):
            return sorted(obj)
        return [normalize(x) for x in obj]
    return obj


def normalize_with_order(obj, _key=None):
    """Like normalize, but preserves revalidation_order list ordering."""
    if isinstance(obj, dict):
        return {
            k: normalize_with_order(v, _key=k)
            for k, v in sorted(obj.items())
        }
    if isinstance(obj, list):
        if _key == "revalidation_order":
            return obj  # order matters
        if all(isinstance(x, str) for x in obj):
            return sorted(obj)
        return [normalize_with_order(x) for x in obj]
    return obj


def run_bash(project_root, direction, changed_id, vmodel_path):
    """Run impact-analysis.sh and return parsed JSON."""
    cmd = [
        "bash",
        os.path.join(project_root, "scripts/bash/impact-analysis.sh"),
        f"--{direction}", "--json", changed_id,
        os.path.join(project_root, vmodel_path),
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
    if result.returncode != 0:
        return None, f"bash exit {result.returncode}: {result.stderr.strip()}"
    try:
        return json.loads(result.stdout), None
    except json.JSONDecodeError as e:
        return None, f"bash JSON decode error: {e}"


def run_pwsh(project_root, direction, changed_id, vmodel_path):
    """Run impact-analysis.ps1 and return parsed JSON."""
    ps_direction = f"-{direction.capitalize()}"
    cmd = [
        "pwsh", "-NoProfile", "-File",
        os.path.join(project_root, "scripts/powershell/impact-analysis.ps1"),
        ps_direction, "-Json", "-Ids", changed_id,
        "-VModelDir", os.path.join(project_root, vmodel_path),
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
    if result.returncode != 0:
        return None, f"pwsh exit {result.returncode}: {result.stderr.strip()}"
    try:
        return json.loads(result.stdout), None
    except json.JSONDecodeError as e:
        return None, f"pwsh JSON decode error: {e}"


def validate_combo(project_root, fixture_set, direction, changed_id, vmodel_path):
    """Run one combo through both scripts and compare.

    Returns (passed: bool, label: str, detail: str | None).
    """
    label = f"{fixture_set}/{direction}-{changed_id}"

    bash_json, bash_err = run_bash(project_root, direction, changed_id, vmodel_path)
    if bash_err:
        return False, label, bash_err

    pwsh_json, pwsh_err = run_pwsh(project_root, direction, changed_id, vmodel_path)
    if pwsh_err:
        return False, label, pwsh_err

    # Compare with ID-list sorting (suspect_artifacts) but order-preserving revalidation_order
    bash_norm = normalize_with_order(bash_json)
    pwsh_norm = normalize_with_order(pwsh_json)

    if bash_norm == pwsh_norm:
        return True, label, None

    # Build diff detail
    diffs = []
    all_keys = set(list(bash_norm.keys()) + list(pwsh_norm.keys()))
    for key in sorted(all_keys):
        bv = bash_norm.get(key)
        pv = pwsh_norm.get(key)
        if bv != pv:
            diffs.append(f"  {key}: bash={bv}  pwsh={pv}")
    return False, label, "JSON mismatch:\n" + "\n".join(diffs)


def validate_all(project_root):
    """Run all combos. Returns (passed_count, failed_count, details)."""
    passed = 0
    failed = 0
    details = []

    for fixture_set, direction, changed_id, vmodel_path in COMBOS:
        ok, label, detail = validate_combo(
            project_root, fixture_set, direction, changed_id, vmodel_path
        )
        if ok:
            passed += 1
            details.append(f"PASS {label}")
        else:
            failed += 1
            details.append(f"FAIL {label}: {detail}")

    return passed, failed, details


def main():
    if len(sys.argv) < 2:
        print(
            f"Usage: {sys.argv[0]} <project_root> [--combo <name> <dir> <id> <path>]",
            file=sys.stderr,
        )
        sys.exit(2)

    project_root = sys.argv[1]
    if not os.path.isdir(project_root):
        print(f"ERROR: {project_root} is not a directory", file=sys.stderr)
        sys.exit(2)

    # Single-combo mode: --combo <fixture_set> <direction> <changed_id> <vmodel_path>
    if len(sys.argv) >= 7 and sys.argv[2] == "--combo":
        fixture_set = sys.argv[3]
        direction = sys.argv[4]
        changed_id = sys.argv[5]
        vmodel_path = sys.argv[6]
        ok, label, detail = validate_combo(
            project_root, fixture_set, direction, changed_id, vmodel_path
        )
        if ok:
            print(f"PASS {label}")
            sys.exit(0)
        else:
            print(f"FAIL {label}: {detail}")
            sys.exit(1)

    # Full mode: run all combos
    passed, failed, details = validate_all(project_root)
    for line in details:
        print(line)
    print(f"\n{passed} passed, {failed} failed")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
