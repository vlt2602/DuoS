# DuoS

DuoS is an independent, open-source, offline-first CarPlay multitasking and
lightweight HUD project for iPhone 7 (A10, arm64), iOS 15.8.8, Dopamine Rootless.

## Current status

**Step 1 only:** this repository contains a buildable scaffold and minimal
Settings bundle. The 4 hook libraries contain **no active hook or functionality**.
Do not expect split screen, car UI input, GPS collection or a speed HUD yet.

## Build through GitHub Actions

1. Create a GitHub repository and upload the **contents** of this DuoS folder.
2. Commit to `main` (or `master`).
3. Navigate to `Actions` -> `Build DuoS Rootless DEB` -> choose a run.
4. Download the `DuoS-rootless-arm64` artifact after the run succeeds.
5. When ready to publish a pre-release, push a tag such as `v0.1.0`.
   The same workflow uploads `packages/*.deb` to GitHub Releases.

The release is marked pre-release because functionality is not yet implemented.

## Local build (macOS with Xcode + Theos)

- THEOS should point to your Theos folder (defaults to `$HOME/theos`).
- Install patched SDK using `$THEOS/bin/install-sdk iPhoneOS16.5`.
- Run `python3 scripts/validate.py`.
- Run `make clean` and then `make package`.
- Rootless output: `packages/*.deb`.

## Security and operational limits

- No license verification, online requests, telemetry, daemons or timers.
- No entitlement spoofing, Scene creation, input forwarding or GPS hooking yet.
- Dynamic libraries are intentionally inert placeholders.
- Do not test driver-interactive functionality while driving.
- Private SpringBoard APIs must be checked on actual iOS 15.8.8 before use.
- Bundled Theos SDK 16.5 requires a compatible macOS/Xcode toolchain.
- The online CI pipeline is separate from the on-device offline design.

See `docs/architecture.md` for the intended module boundaries.

License: MIT.
