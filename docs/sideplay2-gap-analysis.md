# DuoS 0.4.0 — Phân tích chênh lệch SidePlay2 và triển khai mới

## Dữ liệu nguồn đã kiểm tra
File var(1).zip chứa **bản cài đặt đã biên dịch**: SidePlay2.app, sáu .dylib,
PreferenceBundles và các .plist. Không có Makefile, .xm, .m, .h của SidePlay2.
Không thể kết luận mọi chi tiết từ các symbol hay trực tiếp build một bản clone nguyên gốc.

| Cơ chế trong SidePlay2 | Bằng chứng | Trạng thái DuoS |
|---|---|---|
| iPhone app | SidePlay2.app/SidePlay2 | DuoS.app độc lập |
| CarPlay scene | CPTemplateApplicationSceneSessionRoleApplication, SP2CarSceneDelegate trong Info.plist | Thêm SceneDelegate theo API chính thức (yêu cầu entitlement hợp lệ) |
| Nhiều app theo từng pane | SP2Workspace, SP2HostedApp, FBScene | Chưa triển khai nhúng app trong SpringBoard |
| Điều phối touch | sendEvent: và SP2Bubble | Chưa chuyển tiếp cảm ứng |
| HUD nhiều nguồn | 4 thư viện Waze, VietMap, GOFA, WYN | Có HUD layer; thêm GPS thực trên iPhone do người dùng chủ động bật |
| GPS nền, idle lock | các lớp và filter SpringBoard | Không triển khai ép giữ ứng dụng nền |
| UI cấu hình | SidePlay2Prefs.bundle | DuoSPrefs.bundle |

## Điểm khác biệt quan trọng
- **Ứng dụng iPhone**: Có thể chạy độc lập; GPS thực cần xin quyền khi dùng.
- **CarPlay**: Chỉ hoạt động khi CarPlay cho phép mở Scene theo entitlement hợp lệ.
  Khai báo CPTemplateApplicationScene vào Info.plist không tạo ra entitlement.
  Hệ thống kiểm soát vòng đời Scene, giao diện trên xe do template của Apple quản lý.
- **Không giả mạo capability / entitlement** và không loại bỏ hạn chế tương tác lái xe.
- Không mượn nhị phân, hình ảnh hay khóa bản quyền SidePlay2. DuoS dùng mã riêng.

## Kiểm thử cấp độ
1. GitHub Actions: kiểm tra cấu trúc, mã build, file trong gói.
2. iPhone 7: app có mở, GPS xin quyền và dừng khi đưa vào nền.
3. CarPlay thực: chỉ kiểm thử khi có entitlement phù hợp. Không có entitlement thì
   CarPlay Scene *không được bảo đảm sẽ được khởi tạo*, dù CI thành công.
4. Không tương tác khi lái xe. Khóa tương tác nhúng app không được phát triển.

## Việc còn thiếu
- CarPlay app hợp lệ theo danh mục Apple, entitlement thật.
- Thiết kế nội dung điều hướng đủ điều kiện và cấu hình CarPlay phù hợp.
- Kiểm thử vòng đời SpringBoard iOS 15.8.8 trên thiết bị.
- Đánh giá bộ nhớ, xung đột tweak và rollback.

Tham khảo tài liệu Apple Developer: https://developer.apple.com/documentation/carplay/
