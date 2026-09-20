#!/usr/bin/env bash
# Build SmartSelect from source and install it to /Applications.
# Usage: bash scripts/install.sh
set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  echo "SmartSelect is macOS-only." >&2
  exit 1
fi

if ! command -v swift >/dev/null 2>&1; then
  echo "Swift toolchain not found. Install Xcode or the Command Line Tools:" >&2
  echo "  xcode-select --install" >&2
  exit 1
fi

echo "Building SmartSelect.app…"
make app

DEST="/Applications/SmartSelect.app"
echo "Installing to ${DEST}…"
rm -rf "${DEST}"
cp -R build/SmartSelect.app "${DEST}"

echo
echo "Done. Launching — grant Accessibility access when prompted."
echo "  System Settings → Privacy & Security → Accessibility"
open "${DEST}"
