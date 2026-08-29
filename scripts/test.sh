#!/bin/bash

# =============================================================================
# test.sh
# Runs the whole test plan on a simulator that actually exists.
#
#   ./scripts/test.sh                 # newest installed iPhone
#   ./scripts/test.sh "iPhone 17 Pro" # a named one
#
# The destination is resolved at runtime rather than written into the docs, because a
# pinned 'name=iPhone 16 Pro' silently means 'OS:latest' — and the moment Xcode ships a
# runtime that device never shipped on, the documented command fails with "Unable to find
# a device" and nothing in this repository is wrong. CI resolves it the same way.
# =============================================================================

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPTS_DIR")"
cd "$PROJECT_ROOT"

PROJECT="CitroenConnectedCamera.xcodeproj"
SCHEME="Development"
TEST_PLAN="CitroenConnectedCamera"

if [ ! -d "$PROJECT" ]; then
    echo "Error: $PROJECT not found. Generate it first with:"
    echo "  mint run xcodegen generate"
    exit 1
fi

# Newest runtime first, first iPhone on it. A device name passed as $1 narrows the match.
UDID=$(xcrun simctl list devices available --json | NAME_FILTER="${1:-iPhone}" python3 -c '
import json, os, sys
wanted = os.environ["NAME_FILTER"]
devices = json.load(sys.stdin)["devices"]
for runtime in sorted(devices, reverse=True):
    for device in devices[runtime]:
        if device["name"].startswith(wanted):
            print(device["udid"])
            sys.exit(0)
sys.exit(1)
') || {
    echo "Error: no available simulator matching '${1:-iPhone}'. Installed devices:"
    xcrun simctl list devices available | grep -E '^\s{4}\S' || true
    exit 1
}

echo "==> Testing on simulator $UDID"
set -o pipefail
xcodebuild test \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "id=$UDID" \
    -testPlan "$TEST_PLAN" \
    -skipPackagePluginValidation
