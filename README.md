# DuoS 0.4.0 — Bố cục chia hai ô + bong bóng ứng dụng CarPlay

Target: iPhone 7 (A10, arm64), iOS 15.8.8, Dopamine Rootless.
Modules 1 (DRM) and 2 (server interception) are NOT included.

## New in 0.4.0

- Vietnamese toggle **Hiển thị bong bóng DuoS và chia hai ô** (OFF by default).
- On active `com.apple.CarPlayApp` window, a floating **DuoS** button opens
  a split-screen layout preview with independently selectable **left/right** panes.
- 50/50, 60/40 and 40/60 layout ratios (both panes visible).
- The picker lists only **installed** apps from these four allowlisted bundle IDs:
  - Waze: `com.waze.iphone`
  - VietMap Live: `vn.vietmap.live`
  - GOFA: `com.lumi.GOFA`
  - WYN: `com.wynauto.wyn`
- Installed detection uses `LSApplicationProxy` with exact bundle ID and
  non-null bundle URL; if unavailable the picker shows NO applications,
  never a fabricated installed status.
- Picker selections are session-only. Normal CarPlay touches outside the
  overlay continue to pass through.
- No app is installed, launched or modified by this picker.

**Very important: This release is NOT yet true two-app Scene Hosting.**
The two panes are interactive layout placeholders, not live application
frames. The status **Chưa có Scene trực tiếp** is intentional. Implementing
interactive, simultaneous remote app windows requires a verified SpringBoard /
FrontBoard scene-hosting adapter for iOS 15.8.8, plus real vehicle testing.
Compiling on GitHub cannot validate private selectors on the phone.

## How to verify, only while parked

1. Open DuoS in iPhone Settings, enable the bubble option.
2. Reconnect CarPlay while the vehicle is parked.
3. Tap the DuoS bubble, choose the left or right pane.
4. Only installed candidates should appear. Select a candidate and inspect
   its name in the chosen pane. Try each layout ratio and the close button.
5. If no bubble appears, inspect the file
   `/var/mobile/Library/Preferences/com.duos.carplay.log` with Filza and
   the iPhone DuoS status dialog. Actual CarPlayApp injection is unverified.

Never operate the picker or calibration controls while driving. Disable the
feature in Settings before normal driving.

## Existing modules 3–6

- 3: opt-in, CarPlay-state-aware location manager for WYN only.
- 4: local, 64-bit Darwin notify HUD data + view renderer.
- 5: dynamic coordinate math + parked-only calibration overlay.
- 6: SpringBoard boot guard, crash marker and failsafe log.

## Build

GitHub Actions validates plists and C algorithm tests, then builds an
`iphoneos-arm64` Rootless DEB with Theos + SDK 16.5. Run locally:
`python3 scripts/validate.py && bash tests/run.sh && make package`.

Do not interpret a successful build as on-device CarPlay compatibility.

## Fail-safe recovery

Use Dopamine's tweak-disabled launch if SpringBoard fails. DuoS also uses:
`/var/mobile/Library/Preferences/.duos-disabled`
and `/var/mobile/Library/Preferences/com.duos.failsafe.log`.

License: MIT.
