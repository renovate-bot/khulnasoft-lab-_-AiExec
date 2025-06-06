#!/bin/bash
set -x

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
cd "$SCRIPT_DIR/../.."

# libs
pytest src/backend/base/langflow/api/tests/unit_tests
