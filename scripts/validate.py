#!/usr/bin/env python3
"""Kiem tra cau truc va plist truoc khi build. Chi dung thu vien Python co san."""
from pathlib import Path
import plistlib
import sys

root = Path(__file__).resolve().parent.parent
required = [
    'Makefile', 'control', '.github/workflows/build.yml',
    'DuoSCore/Makefile', 'DuoSCore/Tweak.xm', 'DuoSCore/DuoSCore.plist',
    'DuoSApps/Makefile', 'DuoSApps/Tweak.xm', 'DuoSApps/DuoSApps.plist',
    'DuoSHUD/Makefile',
    'DuoSHUD/Renderer/Makefile', 'DuoSHUD/Renderer/Tweak.xm',
    'DuoSHUD/Renderer/DuoSHUD.plist',
    'DuoSHUD/SourceWYN/Makefile', 'DuoSHUD/SourceWYN/Tweak.xm',
    'DuoSHUD/SourceWYN/DuoSHUDWYN.plist',
    'DuoSPrefs/Makefile', 'DuoSPrefs/RootListController.m',
    'DuoSPrefs/Resources/Info.plist', 'DuoSPrefs/Resources/Root.plist',
    'layout/Library/PreferenceLoader/Preferences/com.duos.prefs.plist',
]
errors = []
for path in required:
    if not (root / path).is_file():
        errors.append(f'Missing: {path}')

for file in root.rglob('*.plist'):
    try:
        with file.open('rb') as stream:
            plistlib.load(stream)
    except (ValueError, OSError, TypeError) as exc:
        errors.append(f'Invalid plist: {file.relative_to(root)}: {exc}')

for path, expected in {
    'DuoSCore/DuoSCore.plist': 'com.apple.springboard',
    'DuoSApps/DuoSApps.plist': 'com.apple.UIKit',
    'DuoSHUD/Renderer/DuoSHUD.plist': 'com.apple.springboard',
    'DuoSHUD/SourceWYN/DuoSHUDWYN.plist': 'com.wynauto.wyn'
}.items():
    if not (root / path).is_file():
        continue
    with (root / path).open('rb') as stream:
        data = plistlib.load(stream)
    if expected not in data.get('Filter', {}).get('Bundles', []):
        errors.append(f'Wrong filter: {path}')

if errors:
    print('Validation failed:')
    for issue in errors:
        print(' -', issue)
    sys.exit(1)

print('DuoS scaffold validation OK. All required files and plists are valid.')
