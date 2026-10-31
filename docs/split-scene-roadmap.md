# DuoS split-screen module 0.4 — verified vs unverified

## Implemented
- Two independent layout panes and 50/50, 60/40, 40/60 proportions.
- Floating opt-in CarPlay bubble, panel close, left/right app picker.
- Runtime app-availability lookup through LSApplicationProxy; only these
  installed IDs: com.waze.iphone, vn.vietmap.live, com.lumi.GOFA,
  com.wynauto.wyn.
- Inert fallback label: 'Chưa có Scene trực tiếp'.
- All controls disabled unless user explicitly enables split in Settings;
  calibration overlay takes precedence.

## NOT implemented
- FBSceneHostManager/SBApplicationSceneHandleRequest or live view handoff.
- Launching/hosting arbitrary apps as independent interactive Scene objects.
- Split-screen with two live app views.
- Remote touch routing into a child Scene.
- Persisting selected apps across CarPlay process restart.

## Required actual-device checks before enabling real Scene Hosting
1. Capture SpringBoard and CarPlayApp class/selector availability for
   iOS 15.8.8 (do not guess versions or private method signatures).
2. Verify dashboard application launch method and lifecycle callback.
3. Confirm app Scene ownership, sizing, orientation and safe-area semantics.
4. Test single hosted view before attempting dual hosting.
5. Test disconnection, backgrounding, SpringBoard crash guard,
   and CarPlay reconnect in a parked vehicle.
6. Validate multitouch separately; do not forward global sendEvent: blindly.

Official CarPlay APIs do not provide a generic second app hosting container.
Do not claim a two-pane preview is equivalent to two running applications.
