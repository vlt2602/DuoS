#!/usr/bin/env python3
"""Kiem tra cau truc va plist truoc khi build. Chi dung thu vien Python co san."""
from pathlib import Path
import plistlib
import sys

root = Path(__file__).resolve().parent.parent
required = [
    'Makefile', 'control', '.github/workflows/build.yml',
    'DuoSApp/Makefile', 'DuoSApp/main.m', 'DuoSApp/DuoSAppDelegate.m',
    'DuoSApp/DuoSPhoneSceneDelegate.m', 'DuoSApp/DuoSCarPlaySceneDelegate.m',
    'DuoSApp/DuoSSpeedProvider.m', 'DuoSApp/DuoSSpeedProvider.h',
    'DuoSApp/DuoSRootViewController.m', 'DuoSApp/Resources/Info.plist',
    'DuoSApp/Resources/AppIcon60x60@2x.png',
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

# Kiem tra cong tac an toan: bat buoc OFF khi chua co cau hinh.
settings_path = root / 'DuoSPrefs/Resources/Root.plist'
if settings_path.is_file():
    with settings_path.open('rb') as stream:
        settings = plistlib.load(stream)
    enabled_specs = [
        entry for entry in settings.get('items', [])
        if entry.get('key') == 'enabled'
    ]
    if len(enabled_specs) != 1:
        errors.append('Required: exactly one enabled preference')
    else:
        switch = enabled_specs[0]
        if switch.get('cell') != 'PSSwitchCell':
            errors.append('Invalid safety control: enabled must be PSSwitchCell')
        if switch.get('default') is not False:
            errors.append('Unsafe default: enabled must be false')
        if switch.get('get') != 'readPreferenceValue:':
            errors.append('Missing settings getter')
        if switch.get('set') != 'setPreferenceValue:specifier:':
            errors.append('Missing settings setter')

# Khong duoc phep nham ban xem thu la mot app CarPlay co quyen thuc.
app_info_path = root / 'DuoSApp/Resources/Info.plist'
if app_info_path.is_file():
    with app_info_path.open('rb') as stream:
        app_info = plistlib.load(stream)
    if app_info.get('CFBundleIdentifier') != 'com.duos.app':
        errors.append('Unexpected standalone DuoS app identifier')
    if app_info.get('CFBundlePackageType') != 'APPL':
        errors.append('DuoS app must be an application bundle')
    manifest = app_info.get('UIApplicationSceneManifest', {})
    scenes = manifest.get('UISceneConfigurations', {})
    phone = scenes.get('UIWindowSceneSessionRoleApplication', [])
    car = scenes.get('CPTemplateApplicationSceneSessionRoleApplication', [])
    if not phone or phone[0].get('UISceneDelegateClassName') != 'DuoSPhoneSceneDelegate':
        errors.append('Phone scene delegate is missing or invalid')
    if not car or car[0].get('UISceneClassName') != 'CPTemplateApplicationScene':
        errors.append('CarPlay scene class is missing or invalid')
    if not car or car[0].get('UISceneDelegateClassName') != 'DuoSCarPlaySceneDelegate':
        errors.append('CarPlay scene delegate is missing or invalid')
    if 'NSLocationWhenInUseUsageDescription' not in app_info:
        errors.append('Foreground GPS requires user-facing location permission text')

if errors:
    print('Validation failed:')
    for issue in errors:
        print(' -', issue)
    sys.exit(1)

print('DuoS scaffold validation OK. All required files and plists are valid.')
