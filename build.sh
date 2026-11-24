#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
version=${RELEASE_VERSION:-1.0.1}
mkdir -p dist
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
bundle="$stage/Antigravity Usage.app"
contents="$bundle/Contents"
mkdir -p "$contents/MacOS" "$contents/Resources"
cp app.py index.html "$contents/Resources/"
cp packaging/Info.plist "$contents/"
/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $version" "$contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleVersion string 1' "$contents/Info.plist"
for arch in arm64 x86_64; do
  xcrun swiftc -O -target "$arch-apple-macos13.0" Orb.swift -o "$stage/$arch"
done
lipo -create "$stage/arm64" "$stage/x86_64" -output "$contents/MacOS/UsageOrb"
codesign --force --sign - "$bundle"
codesign --verify --strict "$bundle"
ditto -c -k --keepParent "$bundle" dist/Antigravity-Usage-macOS-universal.zip
