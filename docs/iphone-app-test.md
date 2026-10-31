# Kiểm thử DuoS 0.3.0

Mục tiêu: xác minh ứng dụng DuoS có biểu tượng riêng và mở được trên iPhone 7.

1. Mở Pull Request #1 → Checks → GitHub Actions gần nhất.
2. Kiểm tra các bước Validate, Geometry, Speed và Compile & package đều xanh.
3. Tải artifact DuoS-rootless-arm64; giải nén để lấy file .deb.
4. Chỉ cài thử khi đã có bản sao lưu và cách tắt/gỡ tweak.
5. Sau khi cài gói mới bằng Sileo, làm mới biểu tượng ứng dụng theo hướng dẫn hệ thống hoặc khởi động lại giao diện nếu cần.
6. Tìm ứng dụng DuoS trên màn hình chính. Mở app: thấy bố cục 50/50, 65/35, 1+2; HUD hiển thị tốc độ 88 (dữ liệu mẫu).
7. Kiểm tra Cài đặt → DuoS; công tắc mặc định tắt.

Nếu không thấy icon: trước hết xác minh file `/var/jb/Applications/DuoS.app/Info.plist` trên thiết bị, sau đó kiểm tra đăng ký ứng dụng bằng tiện ích của môi trường jailbreak. Không cố thử can thiệp CarPlay khi chưa có kết quả về quyền và quản lý scene.

Lưu ý: người đang lái xe không nên thao tác thử màn hình. Bản này không có split-screen thật trên CarPlay.
