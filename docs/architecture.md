# DuoS 0.2 — Technical architecture and gaps

Target: iPhone 7 A10, arm64, iOS 15.8.8, Dopamine Rootless.
No DRM, fake network responses, license code or external telemetry.

## Module 6: SpringBoard safety

DuoSCore injects only into com.apple.springboard, starts a boot marker,
writes a local one-line log and marks a healthy start after eight seconds.
On incomplete recent restart (< 90 seconds uptime difference), creates
a persistent disabled flag. The guard cannot catch SIGSEGV or all launch
failures; separate libraries must check this flag before initiating
dangerous functionality. No FBScene hooks are registered.

## Module 3: State-aware location

DuoSCarPlayState uses notify_set_state/get_state with a timestamp and
requires an authenticated **device-specific CarPlay scene callback** to
publish connection state and refresh it at least every 60 seconds.
The source publisher has NOT been connected to iOS 15.8.8's private
CarPlay lifecycle. Until then, status remains disconnected.

DuoSLocationController only manages its own CLLocationManager. It requires
explicit opt-in, an app with UIBackgroundModes=location, Always authorization,
and verified CarPlay connection. It never overwrites an unrelated manager.

## Module 4: IPC + HUD

DuoSHUDCodec packs one atomic 64-bit value (speed tenths, limit, flags,
sequence, uptime). DuoSHUDTransport broadcasts notify events, latest value
wins, without writing high-frequency temporary plist files. Stale data is
rejected after 10 seconds.

DuoSHUDRenderer uses one CATextLayer updated with animations disabled
and only after attach to a verified CarPlay view via
DuoSAttachHUDToCarPlayView(). This API is present but not called by a
live CarPlay Scene adapter. No real speed producer is installed.

## Module 5: Geometry

DuoSTouchMap maps from the *actual viewport* (after cropping/insets)
into logical app coordinates, handling 0/90/180/270-degree rotation.
It rejects all points outside the viewport and non-finite geometry.
No global sendEvent hook is installed; this is deliberate until
private API signatures and coordinate spaces are verified on device.

## Guardrails

- Never create Scene objects by guessing private selectors.
- Never hook arbitrary CLLocationManager instances in third-party apps.
- Do not use constant hardware scale factors for touch mapping.
- Avoid 1-second file I/O and unconditional repeating timers.
- All optional features default OFF.
- Tests cover the pure-C codec and touch mapping only.
- GitHub Actions build/test does not prove correctness on an iPhone.

## Next verified integration points

1. iOS 15.8.8 CarPlay scene lifecycle and on-disconnect callback.
2. Explicit publisher for consented location/speed observations.
3. Verified CarPlay host view for HUD layer ownership.
4. Scene coordinates + touchscreen report path from the real car display.
5. On-device SpringBoard restart, safe mode recovery and power measurements.
