# DuoS — iPhone 7 / iOS 15.8.8 / Dopamine Rootless

**Version 0.2.0 (experimental, not a complete CarPlay split-screen tweak).**
Independent open-source project. Modules 1 (DRM) and 2 (server interception) are
**out of scope** and are not included.

## Module status

| Module | Available now | Still missing |
|---|---|---|
| 3 — GPS | CarPlay verification state bus; opt-in location-controller helper for DuoS-owned apps | Confirmed CarPlay callback on iOS 15.8.8, integration into an app owning CLLocationManager |
| 4 — HUD | Event-driven 64-bit notify IPC, freshness check, CALayer HUD renderer attach API | Validated CarPlay host view and real consented speed data producer |
| 5 — Touch | Pure coordinate transform with inset/rotation handling, native tests | Event-to-Scene adapter and calibration on actual car screen |
| 6 — Failsafe | Persistent boot marker, opt-out on interrupted launch, local logs | Hardware fault-injection verification |

**Important:** Core, Apps and WYN modules do not install private SpringBoard
Scene hooks or alter WYN's existing location manager. No app is launched into a
second CarPlay pane yet. All experimental features default OFF.

## Build and tests

- iOS arm64, deployment target 15.0, Theos with iPhoneOS 16.5 patched SDK.
- GitHub Actions: `Build DuoS Rootless DEB` runs tests, compiles four
  subprojects and uploads the `DuoS-rootless-arm64` artifact.
- On macOS: `bash tests/run.sh && python3 scripts/validate.py && make package`.
- Rootless package appears at `packages/*.deb`.
- Build success is **not** a runtime validation.

## Crash guard recovery

DuoSCore creates `/var/mobile/Library/Preferences/.duos-booting` until
eight seconds after launch. If SpringBoard restarts unexpectedly in that period,
DuoS automatically disables its own features with
`/var/mobile/Library/Preferences/.duos-disabled`.
Log: `/var/mobile/Library/Preferences/com.duos.failsafe.log`.

To manually re-enable for another controlled test, remove
`.duos-disabled` and `.duos-booting` with Filza while DuoS is not loading,
then perform one supervised Respring. **Do not remove these files after a crash
until you have diagnosed the cause.** Disabling via Dopamine's tweak-safe mode
is the recovery option if SpringBoard cannot start.

## Safety

CarPlay connection must be verified from a real callback; Bluetooth or
external-screen discovery is not sufficient. When the verification is absent or
more than 60 seconds old, GPS and HUD are off. This also means the HUD will
not be visible until the car-scene adapter exists.

Do not test interactive CarPlay controls while driving. License: MIT.
See `docs/architecture.md` for integration boundaries and known gaps.
