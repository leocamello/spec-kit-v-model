#!/usr/bin/env python3
"""Parse JUnit XML test results and optional Cobertura XML coverage data.

Outputs structured JSON mapping V-Model scenario IDs (SCN, STS, ITS, UTS)
to test statuses (passed/failed/skipped), plus optional per-module coverage.

Uses only Python standard library — zero external dependencies.
"""

import argparse
import json
import re
import sys
import xml.etree.ElementTree as ET


# V-Model ID patterns per traceability matrix
ID_PATTERNS = {
    "A": re.compile(r"(SCN-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+)"),
    "B": re.compile(r"(STS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+)"),
    "C": re.compile(r"(ITS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+)"),
    "D": re.compile(r"(UTS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+)"),
}


def extract_testcases(junit_path):
    """Parse JUnit XML and extract all testcase elements (MOD-001)."""
    tree = ET.parse(junit_path)
    root = tree.getroot()
    testcases = []

    def _parse_element(elem):
        message = None
        failure = elem.find("failure")
        error = elem.find("error")
        skipped = elem.find("skipped")
        if failure is not None:
            message = failure.get("message", failure.text or "")
        elif error is not None:
            message = error.get("message", error.text or "")
        elif skipped is not None:
            message = skipped.get("message", skipped.text or "")
        return {
            "name": elem.get("name", ""),
            "time": float(elem.get("time", "0")),
            "has_failure": failure is not None or error is not None,
            "has_skipped": skipped is not None,
            "message": message,
        }

    if root.tag == "testsuites":
        for testsuite in root.findall("testsuite"):
            for testcase in testsuite.findall("testcase"):
                testcases.append(_parse_element(testcase))
    elif root.tag == "testsuite":
        for testcase in root.findall("testcase"):
            testcases.append(_parse_element(testcase))
    else:
        print(
            f"WARNING: Unexpected root element <{root.tag}>; expected <testsuites> or <testsuite>",
            file=sys.stderr,
        )

    return testcases


def classify_results(raw_testcases):
    """Classify each testcase as passed/failed/skipped (MOD-002).

    Last occurrence wins for duplicate test names (retry handling).
    """
    results = {}
    order = []

    for tc in raw_testcases:
        status = "passed"
        if tc["has_failure"]:
            status = "failed"
        elif tc["has_skipped"]:
            status = "skipped"

        key = tc["name"]
        if key not in results:
            order.append(key)
        results[key] = {
            "name": tc["name"],
            "status": status,
            "duration": tc["time"],
            "message": tc["message"],
        }

    return [results[k] for k in order]


def extract_coverage(cobertura_path):
    """Parse Cobertura XML and return per-file coverage data (MOD-003)."""
    tree = ET.parse(cobertura_path)
    root = tree.getroot()
    file_coverage = {}

    for package in root.findall(".//package"):
        for cls in package.findall(".//class"):
            filename = cls.get("filename", "")
            line_rate = float(cls.get("line-rate", "0"))
            branch_rate = float(cls.get("branch-rate", "0"))
            lines = cls.findall(".//line")
            line_count = len(lines)

            if filename in file_coverage:
                existing = file_coverage[filename]
                total = existing["line_count"] + line_count
                if total > 0:
                    existing["line_rate"] = (
                        existing["line_rate"] * existing["line_count"]
                        + line_rate * line_count
                    ) / total
                    existing["branch_rate"] = (
                        existing["branch_rate"] * existing["line_count"]
                        + branch_rate * line_count
                    ) / total
                existing["line_count"] = total
            else:
                file_coverage[filename] = {
                    "line_rate": line_rate,
                    "branch_rate": branch_rate,
                    "line_count": line_count,
                }

    return file_coverage


def parse_coverage_map(coverage_map_path):
    """Parse coverage-map.yml (simplified YAML subset) (MOD-004 helper).

    Supports the defined schema:
      mappings:
        - mod_id: MOD-001
          files: ["src/a.py", "src/b.py"]
    """
    mod_files = {}
    current_mod = None

    with open(coverage_map_path, "r") as f:
        for line in f:
            stripped = line.strip()
            if stripped.startswith("- mod_id:"):
                current_mod = stripped.split(":", 1)[1].strip().strip('"').strip("'")
                mod_files[current_mod] = []
            elif stripped.startswith("files:") and current_mod is not None:
                files_str = stripped.split(":", 1)[1].strip()
                if files_str.startswith("["):
                    files_str = files_str.strip("[]")
                    files = [
                        f.strip().strip('"').strip("'")
                        for f in files_str.split(",")
                        if f.strip()
                    ]
                    mod_files[current_mod] = files

    return mod_files


def extract_mod_file_refs(module_design_path):
    """Extract MOD→file mappings from module-design.md by convention (MOD-004 helper).

    Looks for Source File references in each MOD section.
    """
    mod_files = {}
    current_mod = None

    with open(module_design_path, "r") as f:
        for line in f:
            heading_match = re.match(
                r"^###\s+Module:\s+(MOD-\d{3})", line
            )
            if heading_match:
                current_mod = heading_match.group(1)
                mod_files[current_mod] = []
                continue

            if current_mod and line.strip().startswith("**Source File**:"):
                path_part = line.split(":", 1)[1].strip().strip("`").strip('"').strip("'")
                if path_part:
                    mod_files[current_mod].append(path_part)

    return mod_files


def map_coverage_to_modules(
    file_coverage, module_design_path=None, coverage_map_path=None, coverage_threshold=100.0
):
    """Map per-file coverage to MOD-NNN modules (MOD-004)."""
    if coverage_map_path:
        try:
            mod_files = parse_coverage_map(coverage_map_path)
        except Exception as e:
            print(f"WARNING: Failed to parse coverage-map.yml: {e}", file=sys.stderr)
            if module_design_path:
                mod_files = extract_mod_file_refs(module_design_path)
            else:
                return {}
    elif module_design_path:
        mod_files = extract_mod_file_refs(module_design_path)
    else:
        return {}

    module_coverage = {}
    for mod_id, files in mod_files.items():
        total_lines = 0
        weighted_stmt = 0.0
        weighted_branch = 0.0

        for filepath in files:
            if filepath in file_coverage:
                fc = file_coverage[filepath]
                total_lines += fc["line_count"]
                weighted_stmt += fc["line_rate"] * fc["line_count"]
                weighted_branch += fc["branch_rate"] * fc["line_count"]
            else:
                nomatch = True
                for cov_file in file_coverage:
                    if cov_file.endswith(filepath) or filepath.endswith(cov_file):
                        fc = file_coverage[cov_file]
                        total_lines += fc["line_count"]
                        weighted_stmt += fc["line_rate"] * fc["line_count"]
                        weighted_branch += fc["branch_rate"] * fc["line_count"]
                        nomatch = False
                        break
                if nomatch:
                    print(
                        f"WARNING: {mod_id} references '{filepath}' not found in Cobertura XML",
                        file=sys.stderr,
                    )

        if total_lines > 0:
            stmt_pct = round((weighted_stmt / total_lines) * 100, 1)
            branch_pct = round((weighted_branch / total_lines) * 100, 1)
        else:
            stmt_pct = 0.0
            branch_pct = 0.0

        below_threshold = stmt_pct < coverage_threshold or branch_pct < coverage_threshold
        module_coverage[mod_id] = {
            "stmt": stmt_pct,
            "branch": branch_pct,
            "files": files,
            "below_threshold": below_threshold,
            "formatted": f"{stmt_pct}% stmt / {branch_pct}% branch",
        }

    return module_coverage


def match_ids(classified_results):
    """Match classified test results to V-Model IDs (MOD-005)."""
    test_results = []
    unmatched_tests = []
    seen_ids = {}

    for result in classified_results:
        matched = False
        for matrix, pattern in ID_PATTERNS.items():
            m = pattern.search(result["name"])
            if m:
                vid = m.group(1)
                entry = {
                    "id": vid,
                    "matrix": matrix,
                    "status": result["status"],
                    "duration": result["duration"],
                    "message": result["message"],
                }
                if vid in seen_ids:
                    test_results[seen_ids[vid]] = entry
                else:
                    seen_ids[vid] = len(test_results)
                    test_results.append(entry)
                matched = True
                break
        if not matched:
            unmatched_tests.append(result["name"])

    per_matrix = {}
    for label in ("A", "B", "C", "D"):
        matrix_results = [r for r in test_results if r["matrix"] == label]
        per_matrix[label] = {
            "total": len(matrix_results),
            "passed": sum(1 for r in matrix_results if r["status"] == "passed"),
            "failed": sum(1 for r in matrix_results if r["status"] == "failed"),
            "skipped": sum(1 for r in matrix_results if r["status"] == "skipped"),
        }

    summary = {
        "total": len(test_results),
        "passed": sum(1 for r in test_results if r["status"] == "passed"),
        "failed": sum(1 for r in test_results if r["status"] == "failed"),
        "skipped": sum(1 for r in test_results if r["status"] == "skipped"),
        "per_matrix": per_matrix,
        "unmatched_count": len(unmatched_tests),
    }

    return {
        "test_results": test_results,
        "unmatched_tests": unmatched_tests,
        "summary": summary,
    }


def main():
    parser = argparse.ArgumentParser(
        description="Parse JUnit XML test results and optional Cobertura XML coverage data."
    )
    parser.add_argument(
        "--junit", required=True, help="Path to JUnit XML file"
    )
    parser.add_argument(
        "--cobertura", default=None, help="Path to Cobertura XML coverage file"
    )
    parser.add_argument(
        "--coverage-map", default=None, help="Path to coverage-map.yml override"
    )
    parser.add_argument(
        "--module-design", default=None, help="Path to module-design.md for convention-based coverage mapping"
    )
    parser.add_argument(
        "--coverage-threshold",
        type=float,
        default=100.0,
        help="Coverage threshold percentage (default: 100.0)",
    )
    args = parser.parse_args()

    try:
        raw = extract_testcases(args.junit)
    except FileNotFoundError:
        print(json.dumps({"error": f"JUnit XML file not found: {args.junit}"}))
        sys.exit(1)
    except ET.ParseError as e:
        print(json.dumps({"error": f"Invalid JUnit XML: {e}"}))
        sys.exit(1)

    classified = classify_results(raw)
    result = match_ids(classified)

    coverage = {}
    if args.cobertura:
        try:
            file_coverage = extract_coverage(args.cobertura)
            coverage = map_coverage_to_modules(
                file_coverage,
                module_design_path=args.module_design,
                coverage_map_path=args.coverage_map,
                coverage_threshold=args.coverage_threshold,
            )
        except FileNotFoundError:
            print(
                f"WARNING: Cobertura XML file not found: {args.cobertura}",
                file=sys.stderr,
            )
        except ET.ParseError as e:
            print(f"WARNING: Invalid Cobertura XML: {e}", file=sys.stderr)

    output = {
        "test_results": result["test_results"],
        "coverage": {
            mod_id: {
                "stmt": data["stmt"],
                "branch": data["branch"],
                "below_threshold": data["below_threshold"],
                "formatted": data["formatted"],
            }
            for mod_id, data in coverage.items()
        },
        "summary": result["summary"],
        "unmatched_tests": result["unmatched_tests"],
    }

    print(json.dumps(output, indent=2))

    if result["summary"]["total"] == 0:
        sys.exit(2)
    elif result["summary"]["failed"] > 0:
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()
