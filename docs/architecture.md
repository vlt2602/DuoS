# DuoS 0.3 — Architecture, iPhone 7 iOS 15.8.8

## Processes
- DuoSCore: SpringBoard startup guard, no private Scene hooks.
- DuoSApps: pure coordinate module (no active hook into arbitrary UIKit apps).
- DuoSHUD/SourceWYN: local opt-in CoreLocation publisher (no WYN manager override).
- DuoSHUD/Renderer: legacy SpringBoard entry; inactive until explicitly attached.
- DuoSCarPlay: **new**, injected into com.apple.CarPlayApp; watches active UIKit
  windows, publishes a heartbeat, attaches a passive HUD, can display a
  parked-only calibration overlay.
- DuoSPrefs: Vietnamese Settings and a read-only status report.

## Network, permissions, and privacy
No external network calls, telemetry, or license module. GPS requires
explicit user toggle, WYN existing location authorization and verified modes.
One sample per OS location callback, no flash writes every second.

## Runtime caveats
CarPlayApp active window is a PROCESS HEURISTIC. CarPlay class/window hierarchy
must be confirmed on actual iOS 15.8.8. The term 'verified' in the IPC API
means a bounded publisher heartbeat, **not cryptographic vehicle verification**.
If the process does not load on device, no HUD or calibration overlay appears.
Nothing here creates FBScene handles for a second iPhone app.
The test overlay intentionally catches touches only when manually enabled,
and is disabled by default.

## Integration stages
1. Confirm `com.apple.CarPlayApp` process and dynamic library injection
   with local log; adjust filter only after device evidence.
2. Validate HUD status label, then WYN location permission and speed feed.
3. Check touch viewport, orientations and actual car screen in parked vehicle.
4. Test disconnect, car reconnect, GPS end and repeated SpringBoard restart.
5. Real multi-app hosting is an independent workstream with private
   SpringBoard/FrontBoard Scene APIs requiring on-device validation.

## Safety
- Disable advanced modules automatically on unexpected rapid restart.
- No general `sendEvent:` interception.
- No original SidePlay2 binary patches.
- In-car testing must be performed while parked; no driver-facing controls.
