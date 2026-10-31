# DuoS 0.3.0 — iPhone 7 / iOS 15.8.8 / Dopamine Rootless

Open-source local **CarPlay diagnostics and HUD prototype**.
Includes only Modules 3–6; no DRM/license bypass, fake server replies or telemetry.

## What actually works in source

1. **Module 3 — GPS**: a dedicated, opt-in CoreLocation manager starts
   only inside WYN, when WYN has Always location permission,
   `UIBackgroundModes=location`, the user enables GPS, and the CarPlayApp
   observation is recent. Stops on disconnect/expiry (30-second watchdog).
   It never hooks or modifies WYN's own CLLocationManager.
2. **Module 4 — HUD**: WYN can publish real GPS speed (when permitted) through
   Darwin notification 64-bit state; the CarPlayApp module attaches a simple
   noninteractive speed label to a visible CarPlayApp window. An opt-in
   connection-status label helps diagnose the runtime.
3. **Module 5 — Touch**: normalised 0..1000 coordinate mapping plus a
   user-enabled, parked-only touch calibration overlay in CarPlayApp.
   **It does not forward touches into arbitrary applications.**
4. **Module 6 — Failsafe**: SpringBoard boot guard and local safety logs,
   and feature shutdown while disabled.

The entire Preferences pane is in Vietnamese. All user-facing experimental
toggles **default to off**.

## Critical limitation

This does **not** implement DuoDash/SidePlay2 multi-application Scene Hosting,
two-app split screen, or injection of iPhone apps into CarPlay. Those are
separate major features and cannot be honestly inferred from Modules 3–6.

The `com.apple.CarPlayApp` filter and visible-window detection must be
confirmed on a REAL iPhone 7 / iOS 15.8.8 and connected car. Window activity
is a provisional indicator, **not verified physical vehicle connection**.
A green GitHub Actions build does not verify this runtime behavior.

## How to test (vehicle parked)

1. Open GitHub Actions, successful `Build DuoS Rootless DEB`, download artifact
   `DuoS-rootless-arm64`.
2. Install `com.duos.tweak` using Sileo, Respring.
3. On iPhone Settings -> DuoS -> **Kiểm tra trạng thái DuoS**.
4. Enable **Hiển thị nhãn kết nối trên CarPlay**, then reconnect CarPlay
   while the vehicle is parked. A small label should appear on the CarPlayApp
   window if it exists and is active.
5. Check connection state again on iPhone. If disconnected, record
   `/var/mobile/Library/Preferences/com.duos.carplay.log` (Filza) to
   diagnose whether CarPlayApp injected.
6. If available, enable `Bật màn hình kiểm tra điểm chạm` to inspect
   coordinates; turn it **off from iPhone Settings immediately afterward**.
7. To test live speed, enable both GPS and HUD, run WYN with previously
   granted Always location permission and verified location background mode.
   Real speed needs the location publisher; absent publisher, HUD stays hidden.

**Do not use touch calibration or adjust the UI while driving.**

## Build

`bash tests/run.sh && python3 scripts/validate.py && make package`.

GitHub Actions installs Theos SDK 16.5 and builds arm64 Rootless.
The output is a development `.deb`, not a certified vehicle product.

## Recovery

On repeated quick SpringBoard failure, DuoS creates
`/var/mobile/Library/Preferences/.duos-disabled` to disable itself.
Inspect `/var/mobile/Library/Preferences/com.duos.failsafe.log`.
Use Dopamine's tweak-disabled launch if the phone cannot reach the Home Screen.
Only clear the disable marker after diagnosing the cause.

License: MIT. See `docs/architecture.md`.
