#!/usr/bin/env bash

# V-Model directory setup and prerequisite checking script
#
# Usage: ./setup-v-model.sh [OPTIONS]
#
# OPTIONS:
#   --json                        Output in JSON format
#   --require-reqs                Require requirements.md to exist
#   --require-acceptance          Require acceptance-plan.md to exist
#   --require-system-design       Require system-design.md to exist
#   --require-system-test         Require system-test.md to exist
#   --require-architecture-design Require architecture-design.md to exist
#   --require-integration-test    Require integration-test.md to exist
#   --require-module-design       Require module-design.md to exist
#   --require-unit-test           Require unit-test.md to exist
#   --help, -h                    Show help message
#
# OUTPUTS:
#   JSON mode: {"FEATURE_DIR":"...", "VMODEL_DIR":"...", "AVAILABLE_DOCS":[...]}

set -e

JSON_MODE=false
REQUIRE_REQS=false
REQUIRE_ACCEPTANCE=false
REQUIRE_SYSTEM_DESIGN=false
REQUIRE_SYSTEM_TEST=false
REQUIRE_ARCHITECTURE_DESIGN=false
REQUIRE_INTEGRATION_TEST=false
REQUIRE_MODULE_DESIGN=false
REQUIRE_UNIT_TEST=false

for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --require-reqs) REQUIRE_REQS=true ;;
        --require-acceptance) REQUIRE_ACCEPTANCE=true ;;
        --require-system-design) REQUIRE_SYSTEM_DESIGN=true ;;
        --require-system-test) REQUIRE_SYSTEM_TEST=true ;;
        --require-architecture-design) REQUIRE_ARCHITECTURE_DESIGN=true ;;
        --require-integration-test) REQUIRE_INTEGRATION_TEST=true ;;
        --require-module-design) REQUIRE_MODULE_DESIGN=true ;;
        --require-unit-test) REQUIRE_UNIT_TEST=true ;;
        --help|-h)
            cat << 'EOF'
Usage: setup-v-model.sh [OPTIONS]

V-Model directory setup and prerequisite checking.

OPTIONS:
  --json                        Output in JSON format
  --require-reqs                Require requirements.md to exist
  --require-acceptance          Require acceptance-plan.md to exist
  --require-system-design       Require system-design.md to exist
  --require-system-test         Require system-test.md to exist
  --require-architecture-design Require architecture-design.md to exist
  --require-integration-test    Require integration-test.md to exist
  --require-module-design       Require module-design.md to exist
  --require-unit-test           Require unit-test.md to exist
  --help, -h                    Show this help message
EOF
            exit 0
            ;;
        *) echo "ERROR: Unknown option '$arg'" >&2; exit 1 ;;
    esac
done

# Locate repo root and feature directory
get_repo_root() {
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        git rev-parse --show-toplevel
    else
        local script_dir="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        (cd "$script_dir/../../../../.." && pwd)
    fi
}

get_current_branch() {
    if [[ -n "${SPECIFY_FEATURE:-}" ]]; then
        echo "$SPECIFY_FEATURE"
        return
    fi
    if git rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
        git rev-parse --abbrev-ref HEAD
        return
    fi
    local repo_root=$(get_repo_root)
    local specs_dir="$repo_root/specs"
    if [[ -d "$specs_dir" ]]; then
        local latest_feature="" highest=0
        for dir in "$specs_dir"/*; do
            if [[ -d "$dir" ]]; then
                local dirname=$(basename "$dir")
                if [[ "$dirname" =~ ^([0-9]{3})- ]]; then
                    local number=$((10#${BASH_REMATCH[1]}))
                    if [[ "$number" -gt "$highest" ]]; then
                        highest=$number
                        latest_feature=$dirname
                    fi
                fi
            fi
        done
        [[ -n "$latest_feature" ]] && echo "$latest_feature" && return
    fi
    echo "main"
}

find_feature_dir() {
    local repo_root="$1"
    local branch="$2"
    local specs_dir="$repo_root/specs"
    if [[ "$branch" =~ ^([0-9]{3})- ]]; then
        local prefix="${BASH_REMATCH[1]}"
        for dir in "$specs_dir"/"$prefix"-*; do
            [[ -d "$dir" ]] && echo "$dir" && return
        done
    fi
    echo "$specs_dir/$branch"
}

REPO_ROOT=$(get_repo_root)
BRANCH=$(get_current_branch)
FEATURE_DIR=$(find_feature_dir "$REPO_ROOT" "$BRANCH")
VMODEL_DIR="$FEATURE_DIR/v-model"

# Create v-model directory if it doesn't exist
mkdir -p "$VMODEL_DIR"

REQUIREMENTS="$VMODEL_DIR/requirements.md"
ACCEPTANCE="$VMODEL_DIR/acceptance-plan.md"
TRACE_MATRIX="$VMODEL_DIR/traceability-matrix.md"
SYSTEM_DESIGN="$VMODEL_DIR/system-design.md"
SYSTEM_TEST="$VMODEL_DIR/system-test.md"
ARCH_DESIGN="$VMODEL_DIR/architecture-design.md"
INTEGRATION_TEST="$VMODEL_DIR/integration-test.md"
MODULE_DESIGN="$VMODEL_DIR/module-design.md"
UNIT_TEST="$VMODEL_DIR/unit-test.md"
SPEC="$FEATURE_DIR/spec.md"

# Prerequisite checks
if $REQUIRE_REQS && [[ ! -f "$REQUIREMENTS" ]]; then
    echo "ERROR: requirements.md not found in $VMODEL_DIR" >&2
    echo "Run /speckit.v-model.requirements first." >&2
    exit 1
fi

if $REQUIRE_ACCEPTANCE && [[ ! -f "$ACCEPTANCE" ]]; then
    echo "ERROR: acceptance-plan.md not found in $VMODEL_DIR" >&2
    echo "Run /speckit.v-model.acceptance first." >&2
    exit 1
fi

if $REQUIRE_SYSTEM_DESIGN && [[ ! -f "$SYSTEM_DESIGN" ]]; then
    echo "ERROR: system-design.md not found in $VMODEL_DIR" >&2
    echo "Run /speckit.v-model.system-design first." >&2
    exit 1
fi

if $REQUIRE_SYSTEM_TEST && [[ ! -f "$SYSTEM_TEST" ]]; then
    echo "ERROR: system-test.md not found in $VMODEL_DIR" >&2
    echo "Run /speckit.v-model.system-test first." >&2
    exit 1
fi

if $REQUIRE_ARCHITECTURE_DESIGN && [[ ! -f "$ARCH_DESIGN" ]]; then
    echo "ERROR: architecture-design.md not found in $VMODEL_DIR" >&2
    echo "Run /speckit.v-model.architecture-design first." >&2
    exit 1
fi

if $REQUIRE_INTEGRATION_TEST && [[ ! -f "$INTEGRATION_TEST" ]]; then
    echo "ERROR: integration-test.md not found in $VMODEL_DIR" >&2
    echo "Run /speckit.v-model.integration-test first." >&2
    exit 1
fi

if $REQUIRE_MODULE_DESIGN && [[ ! -f "$MODULE_DESIGN" ]]; then
    echo "ERROR: module-design.md not found in $VMODEL_DIR" >&2
    echo "Run /speckit.v-model.module-design first." >&2
    exit 1
fi

if $REQUIRE_UNIT_TEST && [[ ! -f "$UNIT_TEST" ]]; then
    echo "ERROR: unit-test.md not found in $VMODEL_DIR" >&2
    echo "Run /speckit.v-model.unit-test first." >&2
    exit 1
fi

# Build available docs list
docs=()
[[ -f "$SPEC" ]] && docs+=("spec.md")
[[ -f "$REQUIREMENTS" ]] && docs+=("requirements.md")
[[ -f "$ACCEPTANCE" ]] && docs+=("acceptance-plan.md")
[[ -f "$TRACE_MATRIX" ]] && docs+=("traceability-matrix.md")
[[ -f "$SYSTEM_DESIGN" ]] && docs+=("system-design.md")
[[ -f "$SYSTEM_TEST" ]] && docs+=("system-test.md")
[[ -f "$ARCH_DESIGN" ]] && docs+=("architecture-design.md")
[[ -f "$INTEGRATION_TEST" ]] && docs+=("integration-test.md")
[[ -f "$MODULE_DESIGN" ]] && docs+=("module-design.md")
[[ -f "$UNIT_TEST" ]] && docs+=("unit-test.md")

if $JSON_MODE; then
    if [[ ${#docs[@]} -eq 0 ]]; then
        json_docs="[]"
    else
        json_docs=$(printf '"%s",' "${docs[@]}")
        json_docs="[${json_docs%,}]"
    fi
    printf '{"REPO_ROOT":"%s","BRANCH":"%s","FEATURE_DIR":"%s","VMODEL_DIR":"%s","SPEC":"%s","REQUIREMENTS":"%s","ACCEPTANCE":"%s","TRACE_MATRIX":"%s","SYSTEM_DESIGN":"%s","SYSTEM_TEST":"%s","ARCH_DESIGN":"%s","INTEGRATION_TEST":"%s","MODULE_DESIGN":"%s","UNIT_TEST":"%s","AVAILABLE_DOCS":%s}\n' \
        "$REPO_ROOT" "$BRANCH" "$FEATURE_DIR" "$VMODEL_DIR" "$SPEC" "$REQUIREMENTS" "$ACCEPTANCE" "$TRACE_MATRIX" "$SYSTEM_DESIGN" "$SYSTEM_TEST" "$ARCH_DESIGN" "$INTEGRATION_TEST" "$MODULE_DESIGN" "$UNIT_TEST" "$json_docs"
else
    echo "REPO_ROOT: $REPO_ROOT"
    echo "BRANCH: $BRANCH"
    echo "FEATURE_DIR: $FEATURE_DIR"
    echo "VMODEL_DIR: $VMODEL_DIR"
    echo "AVAILABLE_DOCS:"
    [[ -f "$SPEC" ]] && echo "  ✓ spec.md" || echo "  ✗ spec.md"
    [[ -f "$REQUIREMENTS" ]] && echo "  ✓ requirements.md" || echo "  ✗ requirements.md"
    [[ -f "$ACCEPTANCE" ]] && echo "  ✓ acceptance-plan.md" || echo "  ✗ acceptance-plan.md"
    [[ -f "$TRACE_MATRIX" ]] && echo "  ✓ traceability-matrix.md" || echo "  ✗ traceability-matrix.md"
    [[ -f "$SYSTEM_DESIGN" ]] && echo "  ✓ system-design.md" || echo "  ✗ system-design.md"
    [[ -f "$SYSTEM_TEST" ]] && echo "  ✓ system-test.md" || echo "  ✗ system-test.md"
    [[ -f "$ARCH_DESIGN" ]] && echo "  ✓ architecture-design.md" || echo "  ✗ architecture-design.md"
    [[ -f "$INTEGRATION_TEST" ]] && echo "  ✓ integration-test.md" || echo "  ✗ integration-test.md"
    [[ -f "$MODULE_DESIGN" ]] && echo "  ✓ module-design.md" || echo "  ✗ module-design.md"
    [[ -f "$UNIT_TEST" ]] && echo "  ✓ unit-test.md" || echo "  ✗ unit-test.md"
fi
