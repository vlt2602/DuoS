# DuoS

**Status: 0.2.0 - test preview (chua co split-screen tren CarPlay).**

DuoS la du an nguon mo cho iPhone 7 (A10/arm64), iOS 15.8.8, Dopamine Rootless.

## Da hoat dong o muc ma nguon
- Build `.deb` rootless tren GitHub Actions.
- DuoSCore: theo doi man hinh ngoai bang notification, mac dinh TAT.
- Thu vien tinh hai vung 50/50 hoac 65/35; kiem thu tinh toan tu dong.
- Settings: cong tac bat/tat theo doi, xem thu hai bo cuc va HUD so lieu MAU.
- HUD render: su dung CALayer, CATextLayer, CAShapeLayer, khong co timer.
- Khong network, khong telemetry, khong du lieu dinh vi thuc.

## Chua co
- Chua xac minh phien CarPlay rieng biet voi man hinh ngoai.
- Chua nhung app vao FBScene, chua chia man hinh xe.
- Chua touch relay, khong spoof entitlement, chua hook GPS cua WYN.
- Chua kiem thu Runtime tren iPhone 7.

## Build
1. Moi Pull Request kich hoat `.github/workflows/build.yml`.
2. Khi build xanh, tai `DuoS-rootless-arm64` trong tab Actions.
3. Giai nen de lay file DEB. Khong cai len may chinh neu chua kiem thu rollback.

## Viec can lam khi kiem thu tren may
- Xem `docs/windows-qa.md`.
- Thu khi xe do an toan; khong tuong tac khi dang lai xe.
- Thiet ke an toan theo thu tu: Preview -> Ket noi CarPlay -> Test Scene -> Multi-app.

## Giay phep
MIT. Khong sao chep ma nguon cua tweak thuong mai.
