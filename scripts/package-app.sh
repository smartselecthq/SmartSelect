#!/usr/bin/env bash
# Bundles the built `smartselect` executable into a runnable SmartSelect.app.
set -euo pipefail

CONFIG="${1:-release}"
APP_NAME="SmartSelect"
BUNDLE_ID="com.smartselect.app"
BUILD_DIR="build"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
MACOS_DIR="${APP_DIR}/Contents/MacOS"
RES_DIR="${APP_DIR}/Contents/Resources"

BIN_PATH="$(swift build -c "${CONFIG}" --show-bin-path)/smartselect"
if [[ ! -f "${BIN_PATH}" ]]; then
  echo "error: executable not found at ${BIN_PATH} — run 'swift build -c ${CONFIG}' first" >&2
  exit 1
fi

echo "Packaging ${APP_NAME}.app (${CONFIG})…"
rm -rf "${APP_DIR}"
mkdir -p "${MACOS_DIR}" "${RES_DIR}"

cp "${BIN_PATH}" "${MACOS_DIR}/${APP_NAME}"
chmod +x "${MACOS_DIR}/${APP_NAME}"

VERSION="$(git describe --tags --always 2>/dev/null || echo "0.1.0")"

cat > "${APP_DIR}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>            <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>     <string>${APP_NAME}</string>
    <key>CFBundleExecutable</key>      <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>      <string>${BUNDLE_ID}</string>
    <key>CFBundleVersion</key>         <string>${VERSION}</string>
    <key>CFBundleShortVersionString</key><string>${VERSION}</string>
    <key>CFBundlePackageType</key>     <string>APPL</string>
    <key>LSMinimumSystemVersion</key>  <string>12.0</string>
    <!-- Menu-bar agent: no Dock icon, no default window. -->
    <key>LSUIElement</key>             <true/>
    <key>NSHumanReadableCopyright</key><string>MIT License. © 2026 Swathi.</string>
</dict>
</plist>
PLIST

echo "Built ${APP_DIR}"
echo "Launch with: open ${APP_DIR}"
