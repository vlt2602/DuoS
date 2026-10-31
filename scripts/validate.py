#!/usr/bin/env python3
"""DuoS Rootless structure, plist and Vietnamese UI validation."""
from pathlib import Path
import plistlib
import sys

root = Path(__file__).resolve().parent.parent
required = [
    "Makefile","control",".github/workflows/build.yml",
    "DuoSCore/Makefile","DuoSCore/Tweak.xm","DuoSCore/DuoSCrashGuard.m","DuoSCore/DuoSCrashGuard.h","DuoSCore/DuoSCore.plist",
    "DuoSApps/Makefile","DuoSApps/Tweak.xm","DuoSApps/DuoSApps.plist",
    "DuoSHUD/Makefile","DuoSHUD/Renderer/Makefile","DuoSHUD/Renderer/Tweak.xm",
    "DuoSHUD/Renderer/DuoSHUDRenderer.m","DuoSHUD/Renderer/DuoSHUD.plist",
    "DuoSHUD/SourceWYN/Makefile","DuoSHUD/SourceWYN/Tweak.xm","DuoSHUD/SourceWYN/DuoSHUDWYN.plist",
    "DuoSCarPlay/Makefile","DuoSCarPlay/Tweak.xm","DuoSCarPlay/DuoSCarPlay.plist",
    "DuoSCarPlay/DSSplitOverlay.h","DuoSCarPlay/DSSplitOverlay.m",
    "DuoSCarPlay/DSAppCatalog.h","DuoSCarPlay/DSAppCatalog.m",
    "DuoSPrefs/Makefile","DuoSPrefs/RootListController.m","DuoSPrefs/Resources/Info.plist","DuoSPrefs/Resources/Root.plist",
    "layout/Library/PreferenceLoader/Preferences/com.duos.prefs.plist",
    "Shared/DuoSHUDCodec.c","Shared/DuoSHUDCodec.h","Shared/DuoSHUDTransport.m","Shared/DuoSHUDTransport.h",
    "Shared/DuoSTouchMapper.c","Shared/DuoSTouchMapper.h","Shared/DuoSCarPlayState.m","Shared/DuoSCarPlayState.h",
    "Shared/DuoSLocationController.m","Shared/DuoSLocationController.h","tests/run.sh","tests/test_math.c",
]
errors=[]
for path in required:
    if not (root / path).is_file():
        errors.append("Missing: "+path)
for file in root.rglob("*.plist"):
    try:
        with file.open("rb") as f: plistlib.load(f)
    except (ValueError,OSError,TypeError) as exc:
        errors.append(f"Invalid plist {file.relative_to(root)}: {exc}")
for path, expected in {
    "DuoSCore/DuoSCore.plist":"com.apple.springboard",
    "DuoSApps/DuoSApps.plist":"com.apple.UIKit",
    "DuoSHUD/Renderer/DuoSHUD.plist":"com.apple.springboard",
    "DuoSHUD/SourceWYN/DuoSHUDWYN.plist":"com.wynauto.wyn",
    "DuoSCarPlay/DuoSCarPlay.plist":"com.apple.CarPlayApp"
}.items():
    if (root/path).exists():
        with (root/path).open("rb") as f: data=plistlib.load(f)
        if expected not in data.get("Filter",{}).get("Bundles",[]):
            errors.append(f"Wrong bundle filter: {path}")
main=(root/"Makefile").read_text(encoding="utf-8")
if "THEOS_PACKAGE_SCHEME := rootless" not in main or "arm64" not in main or "DuoSCarPlay" not in main:
    errors.append("Rootless arm64/CarPlay subproject missing")
prefs=(root/"DuoSPrefs/Resources/Root.plist")
if prefs.exists():
    with prefs.open("rb") as f: d=plistlib.load(f)
    labels=[s.get("label","") for s in d.get("items",[])]
    if not any("Kiểm tra trạng thái" in s for s in labels):
        errors.append("Vietnamese diagnostic UI missing")
    keys = {s.get("key") for s in d.get("items",[]) if isinstance(s, dict)}
    if "splitEnabled" not in keys:
        errors.append("Split UI switch missing")
    if not any("bong bóng" in s.lower() for s in labels):
        errors.append("Vietnamese four-app bubble title missing")
if errors:
    print("Validation failed:")
    for error in errors: print(" -",error)
    sys.exit(1)
print("DuoS: plists, rootless, Vietnamese UI, and CarPlayApp filter verified.")
