#!/bin/bash
set -e

APP_NAME="PomodoroNotch"
DISPLAY_NAME="番茄时钟"
VERSION="${1:-1.0.0}"
BUILD_DIR=".build/release"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
STAGING=".build/dmg-staging"

echo "=== Building ${APP_NAME} v${VERSION} ==="

# 1. Build release binary
swift build -c release --arch arm64
swift build -c release --arch x86_64 2>/dev/null || echo "(Universal build: arm64 only)"

# 2. Create .app bundle
rm -rf "${BUILD_DIR}/${APP_NAME}.app"
mkdir -p "${BUILD_DIR}/${APP_NAME}.app/Contents/MacOS"
mkdir -p "${BUILD_DIR}/${APP_NAME}.app/Contents/Resources"

cp "${BUILD_DIR}/${APP_NAME}" "${BUILD_DIR}/${APP_NAME}.app/Contents/MacOS/"

# Copy icon if exists
if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "${BUILD_DIR}/${APP_NAME}.app/Contents/Resources/"
    ICON_KEY="<key>CFBundleIconFile</key><string>AppIcon</string>"
else
    ICON_KEY=""
fi

# 3. Create Info.plist
cat > "${BUILD_DIR}/${APP_NAME}.app/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.pomodoro.notch</string>
    <key>CFBundleName</key>
    <string>${DISPLAY_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${DISPLAY_NAME}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    ${ICON_KEY}
</dict>
</plist>
PLIST

# 4. Ad-hoc sign
codesign --force --sign - "${BUILD_DIR}/${APP_NAME}.app"

echo "=== Creating DMG ==="

# 5. Create DMG
rm -rf "${STAGING}" "${DMG_NAME}"
mkdir -p "${STAGING}"
cp -R "${BUILD_DIR}/${APP_NAME}.app" "${STAGING}/"

# Create symlink to /Applications for drag-to-install
ln -s /Applications "${STAGING}/Applications"

hdiutil create -volname "${DISPLAY_NAME}" \
    -srcfolder "${STAGING}" \
    -ov -format UDZO \
    "${DMG_NAME}"

# 6. Sign DMG (adhoc)
codesign --force --sign - "${DMG_NAME}"

rm -rf "${STAGING}"
echo "=== Done: ${DMG_NAME} ==="
ls -lh "${DMG_NAME}"
