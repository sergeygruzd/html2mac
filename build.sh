#!/bin/zsh
# Wraps a single-file web app (a folder with index.html) into a native macOS .app.
# Usage: ./build.sh "<App Name>" <folder-with-index.html> [width] [height] [icon-style]
#   icon-style: "house" for the house icon, otherwise the app's first letter is drawn.
# Example: ./build.sh "Hello" example 900 640
set -e
HERE="${0:A:h}"
cd "$HERE"
[ $# -ge 2 ] || { echo 'usage: ./build.sh "<App Name>" <folder> [width] [height] [icon-style]'; exit 1; }
name="$1"; src_dir="${2:A}"; w="${3:-1100}"; h="${4:-760}"; style="${5:-$name}"
[ -f "$src_dir/index.html" ] || { echo "no index.html in $src_dir"; exit 1; }
bundle_id="io.github.html2mac.$(echo "$name" | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]')"

mkdir -p build
clang -fobjc-arc -O2 WebShell.m -o build/WebShell -framework Cocoa -framework WebKit
clang -fobjc-arc -O2 make_icon.m -o build/make_icon -framework Cocoa

app="build/$name.app"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp build/WebShell "$app/Contents/MacOS/$name"
cp -R "$src_dir"/. "$app/Contents/Resources/"

build/make_icon "build/icon.png" "$style"
iconset="build/icon.iconset"; rm -rf "$iconset"; mkdir "$iconset"
for s in 16 32 128 256 512; do
  sips -z $s $s build/icon.png --out "$iconset/icon_${s}x${s}.png" >/dev/null
  sips -z $((s*2)) $((s*2)) build/icon.png --out "$iconset/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$iconset" -o "$app/Contents/Resources/AppIcon.icns"

cat > "$app/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>$name</string>
  <key>CFBundleDisplayName</key><string>$name</string>
  <key>CFBundleExecutable</key><string>$name</string>
  <key>CFBundleIdentifier</key><string>$bundle_id</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>12.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>WebShellTitle</key><string>$name</string>
  <key>WebShellWidth</key><integer>$w</integer>
  <key>WebShellHeight</key><integer>$h</integer>
</dict></plist>
PLIST
codesign --force --deep -s - "$app" >/dev/null 2>&1 || true
echo "built $HERE/$app  (drag it into /Applications to install)"
