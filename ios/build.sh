#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT="${OUT_DIR:-$ROOT/build}"
APP="$OUT/Payload/HGhub.app"
mkdir -p "$APP"
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
xcrun --sdk iphoneos swiftc "$ROOT/App.swift" -o "$APP/HGhub" \
  -sdk "$SDK" -target arm64-apple-ios15.0 -O -whole-module-optimization \
  -framework UIKit -framework WebKit -framework Foundation \
  -Xlinker -rpath -Xlinker @executable_path/Frameworks
export APP
python3 - <<'PY'
import os,plistlib,pathlib
p=dict(CFBundleIdentifier='com.hghub.huangguo.ios',CFBundleExecutable='HGhub',
 CFBundleName='HGhub',CFBundleDisplayName='HGhub',CFBundlePackageType='APPL',
 CFBundleShortVersionString='1.2.0.9',CFBundleVersion='1209',MinimumOSVersion='15.0',
 CFBundleSupportedPlatforms=['iPhoneOS'],LSRequiresIPhoneOS=True,UIDeviceFamily=[1,2],
 UIRequiredDeviceCapabilities=['arm64'],UILaunchScreen={},
 UISupportedInterfaceOrientations=['UIInterfaceOrientationPortrait','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight'],
 NSAppTransportSecurity={'NSAllowsArbitraryLoads':True,'NSAllowsArbitraryLoadsInWebContent':True},
 HGServerURL=os.environ.get('APP_URL',''),
 CFBundleIcons={'CFBundlePrimaryIcon':{'CFBundleIconFiles':['Icon60@2x','Icon60@3x']}},
 **{'CFBundleIcons~ipad':{'CFBundlePrimaryIcon':{'CFBundleIconFiles':['Icon76@2x','Icon83.5@2x']}}})
pathlib.Path(os.environ['APP'],'Info.plist').write_bytes(plistlib.dumps(p))
PY
swift "$ROOT/icon.swift" "$APP"
plutil -lint "$APP/Info.plist"
lipo -info "$APP/HGhub"
codesign --force --sign - "$APP"
codesign --verify --deep --strict "$APP"
(cd "$OUT" && /usr/bin/zip -qr HGhub-iOS-unsigned.ipa Payload)
unzip -t "$OUT/HGhub-iOS-unsigned.ipa"
