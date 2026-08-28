#!/bin/bash

# =============================================================================
# bootstrap.sh
# One command to take a fresh clone to an openable Xcode project.
#
#   ./scripts/bootstrap.sh
#
# Installs the Mintfile-pinned tools, generates Secrets.xcconfig for Development if an
# envs/.env.development exists, and generates the .xcodeproj. Safe to re-run.
# =============================================================================

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPTS_DIR")"
cd "$PROJECT_ROOT"

if ! command -v mint >/dev/null 2>&1; then
    echo "Error: mint is not installed. Install it with:"
    echo "  brew install mint"
    exit 1
fi

echo "==> Installing pinned tools from Mintfile"
mint bootstrap

echo "==> Generating Configurations/Secrets.xcconfig (development)"
ENV_NAME=development "$SCRIPTS_DIR/generate_secrets.sh"

# Always `mint run`, never a bare `xcodegen` — a bare invocation would run whatever version
# happens to be on PATH, silently bypassing the Mintfile pin.
echo "==> Generating CitroenConnectedCamera.xcodeproj"
mint run xcodegen generate

echo ""
echo "Done. Open it with:"
echo "  open CitroenConnectedCamera.xcodeproj"
