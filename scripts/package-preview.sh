#!/bin/bash
# Build an ad-hoc-signed Apple Silicon preview without a developer certificate.
set -euo pipefail

project_dir="$(cd "$(dirname "$0")/.." && pwd)"
output_dir="${1:-$project_dir/build/preview}"
mkdir -p "$output_dir"
output_dir="$(cd "$output_dir" && pwd)"
derived_data="${JUSTSAYIT_DERIVED_DATA_PATH:-$project_dir/DerivedData}"

cd "$project_dir"
# Use the release identity with faster Swift compilation for the downloadable preview.
xcodebuild -project Fluid.xcodeproj -scheme Fluid -configuration Release \
    -destination 'platform=macOS,arch=arm64' -derivedDataPath "$derived_data" \
    ONLY_ACTIVE_ARCH=YES SWIFT_COMPILATION_MODE=singlefile SWIFT_OPTIMIZATION_LEVEL=-Onone \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

app="$derived_data/Build/Products/Release/Just Say It.app"
helper="$app/Contents/Helpers/fv-serve"
frameworks="$app/Contents/Frameworks"
transcribe="$frameworks/CTranscribe.framework"

test -x "$app/Contents/MacOS/Just Say It"
test -x "$helper"

# The binary Swift package has copies in place of the framework's normal symlinks.
test -f "$transcribe/Versions/A/CTranscribe"
test -d "$transcribe/Versions/A/Resources"
staging="$(mktemp -d "$derived_data/preview-staging.XXXXXX")"
normalized="$staging/CTranscribe.framework"
mkdir -p "$normalized/Versions"
ditto "$transcribe/Versions/A" "$normalized/Versions/A"
ln -s A "$normalized/Versions/Current"
for item in CTranscribe Resources Headers Modules PrivateHeaders; do
    if [ -e "$normalized/Versions/A/$item" ]; then
        ln -s "Versions/Current/$item" "$normalized/$item"
    fi
done
codesign --force --sign - "$normalized"
codesign --verify --strict "$normalized"
mv "$transcribe" "$staging/original.framework"
mv "$normalized" "$transcribe"

for framework in "$frameworks"/*.framework; do
    codesign --force --sign - "$framework"
done
for library in "$frameworks"/*.dylib; do
    if [ -f "$library" ] && [ ! -L "$library" ]; then
        codesign --force --sign - "$library"
    fi
done
cp LICENSE "$app/Contents/Resources/JustSayIt-LICENSE.txt"
source_revision="$(git rev-parse HEAD)"
printf 'Source: https://github.com/kierantrestain/Justsayit/tree/%s\nUpstream: https://github.com/altic-dev/FluidVoice\n' \
    "$source_revision" > "$app/Contents/Resources/JustSayIt-SOURCE.txt"
codesign --force --sign - "$helper"
codesign --force --sign - --entitlements Fluid.entitlements "$app"
codesign --verify --deep --strict "$app"

test "$(plutil -extract CFBundleIdentifier raw "$app/Contents/Info.plist")" = com.kierantrestain.justsayit
test "$(lipo -archs "$app/Contents/MacOS/Just Say It")" = arm64
"$helper" --help >/dev/null

archive="$output_dir/Just-Say-It-macOS-arm64.zip"
ditto -c -k --keepParent "$app" "$staging/Just-Say-It-macOS-arm64.zip"
mv -f "$staging/Just-Say-It-macOS-arm64.zip" "$archive"
printf '%s\n' "$archive"
