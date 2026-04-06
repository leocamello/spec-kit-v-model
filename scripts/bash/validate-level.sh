#!/usr/bin/env bash

# Dispatch wrapper that invokes the correct coverage validator for a given V-level.
#
# After each V-Model level pair is generated, this script selects and runs
# the appropriate validator:
#
#   acceptance       → validate-requirement-coverage.sh
#   system-test      → validate-system-coverage.sh
#   integration-test → validate-architecture-coverage.sh
#   unit-test        → validate-module-coverage.sh
#   hazard-analysis  → validate-hazard-coverage.sh
#
# Usage: ./validate-level.sh [OPTIONS] <vmodel-dir> <level>
#
# OPTIONS:
#   --json      Pass --json to the underlying validator
#   --partial   Pass --partial (only applicable to hazard-analysis)
#
# EXIT CODES:
#   0 = underlying validator passed
#   1 = underlying validator found gaps
#   2 = invalid arguments or unknown level

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

JSON_FLAG=""
PARTIAL_FLAG=""
VMODEL_DIR=""
LEVEL=""

for arg in "$@"; do
    case "$arg" in
        --json) JSON_FLAG="--json" ;;
        --partial) PARTIAL_FLAG="--partial" ;;
        --help|-h)
            echo "Usage: validate-level.sh [--json] [--partial] <vmodel-dir> <level>"
            echo ""
            echo "Levels:"
            echo "  acceptance        → validate-requirement-coverage"
            echo "  system-test       → validate-system-coverage"
            echo "  integration-test  → validate-architecture-coverage"
            echo "  unit-test         → validate-module-coverage"
            echo "  hazard-analysis   → validate-hazard-coverage"
            echo ""
            echo "Options:"
            echo "  --json      Output in JSON format"
            echo "  --partial   Partial mode (hazard-analysis only)"
            echo ""
            echo "Exit codes: 0 = pass, 1 = gaps found, 2 = invalid arguments"
            exit 0
            ;;
        *)
            if [[ -z "$VMODEL_DIR" ]]; then
                VMODEL_DIR="$arg"
            elif [[ -z "$LEVEL" ]]; then
                LEVEL="$arg"
            else
                echo "Error: unexpected argument '$arg'" >&2
                echo "Usage: validate-level.sh [--json] [--partial] <vmodel-dir> <level>" >&2
                exit 2
            fi
            ;;
    esac
done

if [[ -z "$VMODEL_DIR" || -z "$LEVEL" ]]; then
    echo "Error: both <vmodel-dir> and <level> are required" >&2
    echo "Usage: validate-level.sh [--json] [--partial] <vmodel-dir> <level>" >&2
    exit 2
fi

if [[ ! -d "$VMODEL_DIR" ]]; then
    echo "Error: directory '$VMODEL_DIR' does not exist" >&2
    exit 2
fi

case "$LEVEL" in
    acceptance)
        VALIDATOR="validate-requirement-coverage.sh"
        ;;
    system-test)
        VALIDATOR="validate-system-coverage.sh"
        ;;
    integration-test)
        VALIDATOR="validate-architecture-coverage.sh"
        ;;
    unit-test)
        VALIDATOR="validate-module-coverage.sh"
        ;;
    hazard-analysis)
        VALIDATOR="validate-hazard-coverage.sh"
        ;;
    *)
        echo "Error: unknown level '$LEVEL'" >&2
        echo "Valid levels: acceptance, system-test, integration-test, unit-test, hazard-analysis" >&2
        exit 2
        ;;
esac

VALIDATOR_PATH="${SCRIPT_DIR}/${VALIDATOR}"

if [[ ! -f "$VALIDATOR_PATH" ]]; then
    echo "Error: validator not found at '$VALIDATOR_PATH'" >&2
    exit 2
fi

# Build argument list
ARGS=()
[[ -n "$JSON_FLAG" ]] && ARGS+=("$JSON_FLAG")
[[ -n "$PARTIAL_FLAG" && "$LEVEL" == "hazard-analysis" ]] && ARGS+=("$PARTIAL_FLAG")
ARGS+=("$VMODEL_DIR")

exec bash "$VALIDATOR_PATH" "${ARGS[@]}"
