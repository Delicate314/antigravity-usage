#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
version=${RELEASE_VERSION:-1.2.0}
mkdir -p dist
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
bundle="$stage/Antigravity Usage.app"
contents="$bundle/Contents"
mkdir -p "$contents/MacOS" "$contents/Resources"
python3 -m PyInstaller --noconfirm --onefile --name UsageBackend --add-data "index.html:." \
  --specpath "$stage" --workpath "$stage/work" --distpath "$contents/MacOS" app.py
cp packaging/Info.plist "$contents/"
/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $version" "$contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleVersion string 1' "$contents/Info.plist"
arch=$(uname -m)
xcrun swiftc -O -target "$arch-apple-macos13.0" Orb.swift -o "$contents/MacOS/UsageOrb"
/usr/libexec/PlistBuddy -c "Add :LSMinimumSystemVersion string 13.0" "$contents/Info.plist"
codesign --force --sign - "$bundle"
codesign --verify --strict "$bundle"
ditto -c -k --keepParent "$bundle" dist/Antigravity-Usage-macOS-"$arch".zip
