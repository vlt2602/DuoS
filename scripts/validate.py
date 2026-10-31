#!/usr/bin/env python3
"""Repository structure and Rootless safety checks. Python stdlib only."""
from pathlib import Path
import plistlib
import sys

root = Path(__file__).resolve().parent.parent
required = [
    "Makefile", "control", ".github/workflows/build.yml",
    "DuoSCore/Makefile", "DuoSCore/Tweak.xm", "DuoSCore/DuoSCrashGuard.m",
    "DuoSCore/DuoSCrashGuard.h", "DuoSCore/DuoSCore.plist",
    "DuoSApps/Makefile", "DuoSApps/Tweak.xm", "DuoSApps/DuoSApps.plist",
    "DuoSHUD/Makefile",
    "DuoSHUD/Renderer/Makefile", "DuoSHUD/Renderer/Tweak.xm",
    "DuoSHUD/Renderer/DuoSHUDRenderer.m", "DuoSHUD/Renderer/DuoSHUD.plist",
    "DuoSHUD/SourceWYN/Makefile", "DuoSHUD/SourceWYN/Tweak.xm",
    "DuoSHUD/SourceWYN/DuoSHUDWYN.plist",
    "DuoSPrefs/Makefile", "DuoSPrefs/RootListController.m",
    "DuoSPrefs/Resources/Info.plist", "DuoSPrefs/Resources/Root.plist",
    "layout/Library/PreferenceLoader/Preferences/com.duos.prefs.plist",
    "Shared/DuoSHUDCodec.c", "Shared/DuoSHUDCodec.h",
    "Shared/DuoSHUDTransport.m", "Shared/DuoSHUDTransport.h",
    "Shared/DuoSTouchMapper.c", "Shared/DuoSTouchMapper.h",
    "Shared/DuoSCarPlayState.m", "Shared/DuoSCarPlayState.h",
    "Shared/DuoSLocationController.m", "Shared/DuoSLocationController.h",
    "tests/run.sh", "tests/test_math.c",
]
errors = []
for filename in required:
    if not (root / filename).is_file():
        errors.append(f"Missing file: {filename}")

for file in root.rglob("*.plist"):
    try:
        with file.open("rb") as stream:
            plistlib.load(stream)
    except (ValueError, OSError, TypeError) as exc:
        errors.append(f"Invalid plist {file.relative_to(root)}: {exc}")

for path, expected in {
    "DuoSCore/DuoSCore.plist": "com.apple.springboard",
    "DuoSApps/DuoSApps.plist": "com.apple.UIKit",
    "DuoSHUD/Renderer/DuoSHUD.plist": "com.apple.springboard",
    "DuoSHUD/SourceWYN/DuoSHUDWYN.plist": "com.wynauto.wyn",
}.items():
    if not (root / path).is_file():
        continue
    with (root / path).open("rb") as stream:
        actual = plistlib.load(stream).get("Filter", {}).get("Bundles", [])
    if expected not in actual:
        errors.append(f"Incorrect filter: {path}")

makefile = (root / "Makefile").read_text(encoding="utf-8")
if "THEOS_PACKAGE_SCHEME := rootless" not in makefile or "arm64" not in makefile:
    errors.append("Rootless arm64 build setting missing")
control = (root / "control").read_text(encoding="utf-8")
if "Architecture: iphoneos-arm64" not in control:
    errors.append("Wrong package architecture")

if errors:
    print("Validation failed:")
    for error in errors:
        print(" -", error)
    sys.exit(1)
print("DuoS validation passed: plists, layout, Rootless and module files.")
