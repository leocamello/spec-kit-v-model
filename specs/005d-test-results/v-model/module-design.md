# Module Design: Test Results Ingestion

**Feature Branch**: `feature/005d-test-results`
**Created**: 2026-04-05
**Status**: Approved
**Source**: `specs/005d-test-results/v-model/architecture-design.md`

## Overview

This document details the internal design of each architecture module from `architecture-design.md`, specifying function signatures, algorithms, data structures, and error handling. The Test Results Ingestion feature contains 9 modules: 5 within the Python helper (`parse_test_results.py`) and 4 within the Bash/PowerShell wrappers. All modules are 100% deterministic with no AI dependency. The Python modules use only standard library imports.

## ID Schema

- **Module Design**: `MOD-NNN` — sequential identifier for each module
- **Parent Architecture Module**: `ARCH-NNN` reference per module
- Example: `MOD-001` implements `ARCH-001` (JUnit Testcase Extractor)

## Module Designs

### Module: MOD-001 (JUnit Testcase Extractor)

**Parent Architecture Modules**: ARCH-001
**Source File**: `scripts/python/parse_test_results.py`

#### Algorithm View

```
FUNCTION extract_testcases(junit_path: str) -> List[Dict]:
    tree = ET.parse(junit_path)
    root = tree.getroot()

    testcases = []
    IF root.tag == 'testsuites':
        FOR testsuite IN root.findall('testsuite'):
            FOR testcase IN testsuite.findall('testcase'):
                testcases.append(parse_testcase_element(testcase))
    ELIF root.tag == 'testsuite':
        FOR testcase IN root.findall('testcase'):
            testcases.append(parse_testcase_element(testcase))

    RETURN testcases

FUNCTION parse_testcase_element(elem: ET.Element) -> Dict:
    RETURN {
        'name': elem.get('name', ''),
        'time': float(elem.get('time', '0')),
        'has_failure': elem.find('failure') is not None or elem.find('error') is not None,
        'has_skipped': elem.find('skipped') is not None,
        'message': extract_message(elem)
    }
```

#### Data Structure View

```python
# Input: JUnit XML file path (str)
# Output: List of raw testcase records
RawTestcase = {
    'name': str,          # testcase name attribute
    'time': float,        # execution duration in seconds
    'has_failure': bool,  # True if <failure> or <error> child present
    'has_skipped': bool,  # True if <skipped> child present
    'message': str | None # failure/skip message text
}
```

#### Error Handling

- File not found → raise `FileNotFoundError` with path
- Invalid XML → raise `ET.ParseError` with line info
- Missing `name` attribute → use empty string, report in stderr

---

### Module: MOD-002 (Test Result Classifier)

**Parent Architecture Modules**: ARCH-002
**Source File**: `scripts/python/parse_test_results.py`

#### Algorithm View

```
FUNCTION classify_results(raw_testcases: List[Dict]) -> List[Dict]:
    results = OrderedDict()  # keyed by extracted V-Model ID or full name

    FOR tc IN raw_testcases:
        status = 'passed'
        IF tc['has_failure']:
            status = 'failed'
        ELIF tc['has_skipped']:
            status = 'skipped'

        # Last occurrence wins (deduplication for retries)
        results[tc['name']] = {
            'name': tc['name'],
            'status': status,
            'duration': tc['time'],
            'message': tc['message']
        }

    RETURN list(results.values())
```

#### Data Structure View

```python
ClassifiedResult = {
    'name': str,           # full testcase name
    'status': str,         # 'passed' | 'failed' | 'skipped'
    'duration': float,     # seconds
    'message': str | None  # failure/skip message
}
```

#### Error Handling

- Empty input list → return empty list (not an error)
- Testcase with both `<failure>` and `<skipped>` → failure takes precedence

---

### Module: MOD-003 (Cobertura Coverage Extractor)

**Parent Architecture Modules**: ARCH-003
**Source File**: `scripts/python/parse_test_results.py`

#### Algorithm View

```
FUNCTION extract_coverage(cobertura_path: str) -> Dict[str, Dict]:
    tree = ET.parse(cobertura_path)
    root = tree.getroot()
    file_coverage = {}

    FOR package IN root.findall('.//package'):
        FOR cls IN package.findall('class'):
            filename = cls.get('filename', '')
            line_rate = float(cls.get('line-rate', '0'))
            branch_rate = float(cls.get('branch-rate', '0'))
            # Count lines for weighted aggregation
            lines = cls.findall('.//line')
            line_count = len(lines)

            file_coverage[filename] = {
                'line_rate': line_rate,
                'branch_rate': branch_rate,
                'line_count': line_count
            }

    RETURN file_coverage
```

#### Data Structure View

```python
# Output: Per-file coverage data
FileCoverage = {
    'line_rate': float,    # 0.0–1.0
    'branch_rate': float,  # 0.0–1.0
    'line_count': int      # total lines for weighting
}
# Dict[filename: str, FileCoverage]
```

#### Error Handling

- File not found → raise `FileNotFoundError`
- Invalid XML → raise `ET.ParseError`
- Missing coverage attributes → default to 0.0

---

### Module: MOD-004 (Coverage Module Mapper)

**Parent Architecture Modules**: ARCH-004
**Source File**: `scripts/python/parse_test_results.py`

#### Algorithm View

```
FUNCTION map_coverage_to_modules(
    file_coverage: Dict[str, Dict],
    module_design_path: str | None,
    coverage_map_path: str | None,
    coverage_threshold: float
) -> Dict[str, Dict]:

    # Step 1: Build MOD → files mapping
    IF coverage_map_path is not None:
        mod_files = parse_coverage_map(coverage_map_path)
    ELIF module_design_path is not None:
        mod_files = extract_mod_file_refs(module_design_path)
    ELSE:
        RETURN {}

    # Step 2: Aggregate per-module coverage
    module_coverage = {}
    FOR mod_id, files IN mod_files.items():
        total_lines = 0
        weighted_stmt = 0.0
        weighted_branch = 0.0

        FOR filepath IN files:
            IF filepath IN file_coverage:
                fc = file_coverage[filepath]
                total_lines += fc['line_count']
                weighted_stmt += fc['line_rate'] * fc['line_count']
                weighted_branch += fc['branch_rate'] * fc['line_count']

        IF total_lines > 0:
            stmt_pct = round((weighted_stmt / total_lines) * 100, 1)
            branch_pct = round((weighted_branch / total_lines) * 100, 1)
        ELSE:
            stmt_pct = 0.0
            branch_pct = 0.0

        below_threshold = stmt_pct < coverage_threshold or branch_pct < coverage_threshold
        module_coverage[mod_id] = {
            'stmt': stmt_pct,
            'branch': branch_pct,
            'files': files,
            'below_threshold': below_threshold,
            'formatted': f"{stmt_pct}% stmt / {branch_pct}% branch"
        }

    RETURN module_coverage
```

#### Data Structure View

```python
# coverage-map.yml structure (parsed as simple YAML)
CoverageMap = {
    'mappings': [
        {'mod_id': 'MOD-001', 'files': ['src/reader.py', 'src/reader_utils.py']},
        {'mod_id': 'MOD-002', 'files': ['src/writer.py']}
    ]
}

# Output: Per-module coverage
ModuleCoverage = {
    'stmt': float,            # percentage, one decimal
    'branch': float,          # percentage, one decimal
    'files': List[str],       # source files contributing
    'below_threshold': bool,  # True if below extension.yml threshold
    'formatted': str          # "98.2% stmt / 94.1% branch"
}
```

#### Error Handling

- coverage-map.yml parse error → report and fall back to convention mode
- Module references file not in Cobertura XML → skip with warning
- Zero mapped files for a module → report as 0% coverage

---

### Module: MOD-005 (V-Model ID Regex Matcher)

**Parent Architecture Modules**: ARCH-005
**Source File**: `scripts/python/parse_test_results.py`

#### Algorithm View

```
ID_PATTERNS = {
    'A': re.compile(r'(SCN-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+)'),
    'B': re.compile(r'(STS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+)'),
    'C': re.compile(r'(ITS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+)'),
    'D': re.compile(r'(UTS-[A-Z]*-?[0-9]{3}-[A-Z][0-9]+)')
}

FUNCTION match_ids(classified_results: List[Dict]) -> Dict:
    test_results = []
    unmatched_tests = []

    FOR result IN classified_results:
        matched = False
        FOR matrix, pattern IN ID_PATTERNS.items():
            match = pattern.search(result['name'])
            IF match:
                test_results.append({
                    'id': match.group(1),
                    'matrix': matrix,
                    'status': result['status'],
                    'duration': result['duration'],
                    'message': result['message']
                })
                matched = True
                BREAK
        IF NOT matched:
            unmatched_tests.append(result['name'])

    RETURN {
        'test_results': test_results,
        'unmatched_tests': unmatched_tests,
        'summary': compute_summary(test_results)
    }
```

#### Data Structure View

```python
# Output structure
MatchResult = {
    'test_results': [
        {'id': str, 'matrix': str, 'status': str, 'duration': float, 'message': str | None}
    ],
    'unmatched_tests': [str],      # test names with no V-Model ID
    'summary': {
        'total': int,
        'passed': int,
        'failed': int,
        'skipped': int,
        'per_matrix': {
            'A': {'passed': int, 'failed': int, 'skipped': int, 'total': int},
            'B': {...},
            'C': {...},
            'D': {...}
        }
    }
}
```

#### Error Handling

- No matches at all → return empty `test_results` and full `unmatched_tests` (caller decides exit code)
- Multiple ID patterns match same test name → first match wins (SCN checked before STS/ITS/UTS)

---

### Module: MOD-006 (Matrix Row Updater)

**Parent Architecture Modules**: ARCH-006
**Source File**: `scripts/bash/ingest-test-results.sh` (and PowerShell equivalent)

#### Algorithm View

```
FUNCTION update_matrix(matrix_path, test_results, date, commit, module_coverage):
    lines = read_file(matrix_path)
    output_lines = []
    current_matrix_section = None
    header_updated = False

    FOR line IN lines:
        # Detect matrix section headers
        IF line matches "## Matrix A" → current_matrix_section = 'A'
        IF line matches "## Matrix B" → current_matrix_section = 'B'
        IF line matches "## Matrix C" → current_matrix_section = 'C'
        IF line matches "## Matrix D" → current_matrix_section = 'D'

        IF line is a table header row AND NOT header_updated for this section:
            line = add_columns_to_header(line, current_matrix_section, module_coverage)
            header_updated = True
        ELIF line is a table separator row:
            line = add_columns_to_separator(line, current_matrix_section, module_coverage)
        ELIF line is a table data row:
            FOR result IN test_results:
                IF result['id'] found in line:
                    line = replace_status(line, result['status'])
                    line = set_date_commit(line, date, commit)
                    IF current_matrix_section == 'D' AND module_coverage:
                        line = set_coverage(line, result, module_coverage)
                    BREAK

        output_lines.append(line)

    write_file(matrix_path, output_lines)
```

#### Error Handling

- Matrix file not found → exit with error message
- Row with ID but no Status column → skip with warning
- Malformed table rows → preserve as-is (do not corrupt)

---

### Module: MOD-007 (Ingestion Summary Formatter)

**Parent Architecture Modules**: ARCH-007
**Source File**: `scripts/bash/ingest-test-results.sh` (and PowerShell equivalent)

#### Algorithm View

```
FUNCTION format_summary(results_json, coverage_json, input_file, matrix_path, commit, date):
    IF json_mode:
        output JSON combining results_json and coverage_json
        RETURN

    PRINT "Test Results Ingestion Summary"
    PRINT "══════════════════════════════"
    PRINT "Input:    {input_file} ({total} test cases)"
    PRINT "Matrix:   {matrix_path}"
    PRINT "Commit:   {commit}"
    PRINT "Date:     {date}"
    PRINT ""

    FOR matrix_name IN ['A (Acceptance)', 'B (System)', 'C (Integration)', 'D (Unit)']:
        counts = results_json['summary']['per_matrix'][matrix_letter]
        PRINT "Matrix {matrix_name}: {passed} passed, {failed} failed, {skipped} skipped"

    PRINT ""
    PRINT "Overall: {total_passed} passed, {total_failed} failed, {total_skipped} skipped"

    IF coverage_json:
        PRINT ""
        PRINT "Coverage:"
        FOR mod_id, data IN coverage_json.items():
            flag = " ⚠ Below threshold" IF data['below_threshold'] ELSE ""
            PRINT "  {mod_id}: {data['formatted']}{flag}"
```

#### Error Handling

- Missing summary fields → show "N/A" instead of crashing
- JSON mode with malformed data → output error JSON and exit 1

---

### Module: MOD-008 (Bash Ingestion Orchestrator)

**Parent Architecture Modules**: ARCH-008
**Source File**: `scripts/bash/ingest-test-results.sh`

#### Algorithm View

```
FUNCTION main():
    # 1. Parse arguments
    parse_args(--input, --coverage, --matrix, --coverage-map, --commit-sha, --json, --help)
    IF --help: print_usage(); exit 0

    # 2. Validate required args
    IF NOT --input: error("--input is required"); exit 1
    IF NOT file_exists(--input): error("JUnit XML not found"); exit 1

    # 3. Resolve matrix path
    IF --matrix:
        matrix_path = --matrix
    ELSE:
        setup_json = run("setup-v-model.sh --json")
        matrix_path = setup_json['TRACE_MATRIX']

    # 4. Resolve commit SHA
    IF --commit-sha:
        commit = substring(--commit-sha, 0, 7)
    ELSE:
        commit = run("git rev-parse --short HEAD")

    # 5. Get current date
    date = run("date -u +%Y-%m-%d")

    # 6. Invoke Python helper
    python_args = "--junit ${input}"
    IF --coverage: python_args += " --cobertura ${coverage}"
    IF --coverage-map: python_args += " --coverage-map ${coverage_map}"

    python_output = run("python3 parse_test_results.py ${python_args}")
    IF python exit != 0: error("Python helper failed"); exit 1

    # 7. Check for matches
    total_matched = json_query(python_output, '.summary.total')
    IF total_matched == 0: print_summary(); exit 2

    # 8. Update matrix
    update_matrix(matrix_path, python_output, date, commit)

    # 9. Print summary
    format_summary(python_output, ...)

    # 10. Determine exit code
    IF json_query(python_output, '.summary.failed') > 0: exit 1
    ELSE: exit 0
```

#### Error Handling

- Missing Python 3 → check `command -v python3` and exit with clear error
- Missing `setup-v-model.sh` → error if `--matrix` not provided
- All Python subprocess failures → propagated with stderr

---

### Module: MOD-009 (PowerShell Ingestion Orchestrator)

**Parent Architecture Modules**: ARCH-009
**Source File**: `scripts/powershell/Ingest-Test-Results.ps1`

Mirrors MOD-008 with PowerShell idioms:
- `param()` block for `-Input`, `-Coverage`, `-Matrix`, `-CoverageMap`, `-CommitSha`, `-Json`, `-Help`
- `python3` invocation via `& python3` with `2>&1` and string filtering (learned from 005c CI fixes)
- JSON parsing via `ConvertFrom-Json`
- String manipulation via `-replace` and PowerShell string indexing
- Exit via `exit $exitCode`
- `@()` array wrapping for `Where-Object` results (learned from 005c CI fixes)

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total Module Designs (MOD) | 9 |
| Total Parent ARCH Modules Covered | 9 / 9 (100%) |
| **Forward Coverage (ARCH→MOD)** | **100%** |

### Forward Coverage Detail

| ARCH ID | Covered By |
|---------|-----------|
| ARCH-001 | MOD-001 |
| ARCH-002 | MOD-002 |
| ARCH-003 | MOD-003 |
| ARCH-004 | MOD-004 |
| ARCH-005 | MOD-005 |
| ARCH-006 | MOD-006 |
| ARCH-007 | MOD-007 |
| ARCH-008 | MOD-008 |
| ARCH-009 | MOD-009 |
