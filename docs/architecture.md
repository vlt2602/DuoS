# DuoS architecture (Step 1)

## Process boundaries

- `DuoSCore` -> SpringBoard: future scene lifecycle/layout manager.
- `DuoSApps` -> UIKit-based applications: future opt-in layout/keyboard compatibility.
- `DuoSHUD/Renderer` -> SpringBoard: future CALayer HUD presentation.
- `DuoSHUD/SourceWYN` -> WYN: future local data adapter.
- `DuoSPrefs` -> Settings: currently an informational static screen.

## Rules for future work

1. Fail closed if a private selector/class is missing. No unconditional hooks.
2. Do not actively acquire location unless the user enables the feature and it is needed.
3. Do not retain app scene objects beyond their lifecycle.
4. IPC messages are local, versioned, and bounded in size.
5. No network code, tracking SDK, high-frequency timer, or license service.
6. Avoid driver-facing distractions; verify safety and vehicle compatibility.
7. Code signing and packaging do not guarantee runtime compatibility.

## Planned deployment tree

Under /var/jb/Library/MobileSubstrate/DynamicLibraries:
DuoSCore.dylib/plist, DuoSApps.dylib/plist, DuoSHUD.dylib/plist,
DuoSHUDWYN.dylib/plist.

Under /var/jb/Library/PreferenceBundles: DuoSPrefs.bundle.
Under /var/jb/Library/PreferenceLoader/Preferences: com.duos.prefs.plist.
