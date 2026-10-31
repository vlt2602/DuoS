# DuoS 0.3.0 — Ứng dụng xem thử và bộ khung Rootless

DuoS là dự án nguồn mở thử nghiệm giao diện đa vùng và HUD, nhắm tới iPhone 7, iOS 15.8.8, Dopamine Rootless.

## Có thể kiểm tra trong bản 0.3.0
- Ứng dụng **DuoS** cài riêng ở màn hình chính iPhone (bundle `com.duos.app`).
- Màn hình xem thử bố cục 50/50, 65/35 hoặc 50/25/25; chỉ là hình minh họa, không mở ứng dụng khác.
- Bộ HUD dùng CALayer/CATextLayer/CAShapeLayer, hiển thị tốc độ mẫu 88 km/h.
- Mục DuoS trong Cài đặt vẫn giữ, công tắc theo dõi màn hình ngoài mặc định TẮT.
- Logic hình học và kiểm tra mẫu tốc độ có kiểm thử tự động.
- Không kết nối máy chủ, không có cơ chế giấy phép, không thu thập GPS.

## Chưa có
- Không hiển thị được DuoS trên CarPlay bằng bản này.
- Không sử dụng quyền CarPlay hay giả mạo quyền CarPlay.
- Không nhúng ứng dụng, không chuyển tiếp cảm ứng và không giữ ứng dụng nền.
- Các bước kiểm tra CarPlay thật và ổn định iPhone 7 cần xác minh trên thiết bị.

## Build
- GitHub Actions tạo gói .deb Rootless chứa cả tweak và `/var/jb/Applications/DuoS.app`.
- Kiểm tra nội dung artifact trong Jobs trước khi cài thử.
- Không cài bản chưa kiểm chứng lên điện thoại chính.

## Lưu ý
SidePlay2 đính kèm trước đây là gói đã biên dịch, không phải mã nguồn được cấp phép để sao chép. Chỉ tham khảo kiến trúc và sử dụng mã độc lập.

License: MIT.
