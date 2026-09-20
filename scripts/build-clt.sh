#!/usr/bin/env bash
# Build SmartSelect.app WITHOUT a full Xcode install — using only the Command Line
# Tools (swiftc + the macOS SDK). SwiftPM (`swift build`) requires the Xcode platform
# and fails with "unable to lookup item 'PlatformPath'" on CLT-only machines; this
# script side-steps SwiftPM entirely.
#
# Prefer `make app` (SwiftPM) if you have full Xcode; use this as the fallback.
set -euo pipefail

APP_NAME="SmartSelect"
BUNDLE_ID="com.smartselect.app"
BUILD_DIR="build"
OBJ_DIR="${BUILD_DIR}/clt"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
MACOS_DIR="${APP_DIR}/Contents/MacOS"

SDK="$(xcrun --sdk macosx --show-sdk-path)"
echo "Using SDK: ${SDK}"

rm -rf "${OBJ_DIR}" "${APP_DIR}"
mkdir -p "${OBJ_DIR}" "${MACOS_DIR}"

echo "1/3  Building SmartSelectCore (static library)…"
swiftc -sdk "${SDK}" -O \
  -module-name SmartSelectCore \
  -emit-module -emit-module-path "${OBJ_DIR}/SmartSelectCore.swiftmodule" \
  -emit-library -static -o "${OBJ_DIR}/libSmartSelectCore.a" \
  Sources/SmartSelectCore/*.swift

echo "2/3  Building ${APP_NAME} executable…"
swiftc -sdk "${SDK}" -O \
  -I "${OBJ_DIR}" -L "${OBJ_DIR}" -lSmartSelectCore \
  -o "${MACOS_DIR}/${APP_NAME}" \
  Sources/SmartSelectApp/*.swift

echo "3/3  Writing Info.plist…"
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
    <key>LSUIElement</key>             <true/>
    <key>NSHumanReadableCopyright</key><string>MIT License. © 2026 Swathi.</string>
</dict>
</plist>
PLIST

echo "Built ${APP_DIR}"
echo "Launch with: open ${APP_DIR}"
