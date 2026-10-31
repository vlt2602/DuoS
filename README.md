# DuoS 0.4.0 — nguồn mở / Rootless

**Hiện trạng:** Ứng dụng iPhone có dữ liệu tốc độ GPS thật theo yêu cầu; bộ khung CarPlay theo API chính thức đã được khai báo nhưng không được phép hoạt động nếu chưa có entitlement phù hợp. Chưa có tính năng chia nhiều app thật trong CarPlay.

## Đã làm
- DuoS.app, giao diện bố cục 50/50, 65/35, 50/25/25.
- GPS thực của thiết bị iPhone: chỉ hoạt động khi người dùng chạm Bật GPS, hỏi quyền While In Use và dừng ngay lúc app vào nền. Không thu thập/lưu tọa độ hoặc gửi dữ liệu mạng.
- HUD vẽ bằng CALayer, CATextLayer, CAShapeLayer, không timer.
- Info.plist: Phone UIWindowScene, CPTemplateApplicationScene; CPListTemplate trên xe dùng nếu hệ thống cho phép Scene.
- Theos Rootless, ARM64, iOS 15.0+, CI GitHub Actions với kiểm thử geometry, speed validation và nội dung .deb.
- Tweak SpringBoard vẫn chỉ theo dõi màn hình ngoài khi bật. Không hook scene hoặc UIApplicationEvent.

## Không triển khai
- Bypass quyền CarPlay, chuyển tiếp sự kiện để mở ứng dụng bất kỳ, tắt biện pháp an toàn của hệ thống.
- Chạy nền vô hạn, tự động bật GPS, thu thập telemetry/mạng.
- Không tuyên bố clone hoàn chỉnh SidePlay2 từ file nhị phân.

## Hướng dẫn kiểm thử
1. Mở Pull Request #1, Actions, xem run mới nhất màu xanh.
2. Cài .deb trên máy thử có phương án khôi phục.
3. Mở DuoS.app; xác minh có Bật GPS thực. Khi xin quyền, chọn Khi dùng ứng dụng nếu đồng ý.
4. Bật GPS rồi kiểm tra số tốc độ thực; về màn hình chính phải ngừng cập nhật.
5. Chỉ kiểm thử CarPlay Scene khi sở hữu entitlement ứng dụng phù hợp.

Xem docs/sideplay2-gap-analysis.md để biết ma trận chức năng.
