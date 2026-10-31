# DuoS 0.2.0 — Quy trình kiểm tra trên Windows

## Kiểm tra trên GitHub
1. Mở Pull Request #1 và xem Checks.
2. Xác nhận Validate repository and property lists, Verify two-pane geometry, Compile and package rootless đều xanh.
3. Xác nhận có artifact DuoS-rootless-arm64.

## Kiểm tra trên iPhone thử nghiệm
- Chỉ kiểm tra khi đã có bản sao lưu và phương án xử lý nếu hệ thống gặp lỗi.
- Cài bản test và mở Cài đặt > DuoS.
- Công tắc Theo dõi màn hình ngoài phải mặc định TẮT.
- Chọn Xem thử HUD (không GPS); giá trị 88 chỉ là dữ liệu mẫu, không phải tốc độ thực.
- Chọn Xem thử chia màn hình; đổi 50/50 và 65/35 để xem hai vùng A/B.
- Nếu menu lỗi hoặc ứng dụng Cài đặt bị thoát, dừng kiểm tra và xem nhật ký.

## Giới hạn
- Build thành công không chứng minh CarPlay đã được hỗ trợ.
- UIScreen không thể phân biệt chắc chắn CarPlay với màn hình ngoài khác.
- Không thử tương tác khi đang lái xe; không cài trên thiết bị chính trước kiểm thử phục hồi.
- Không có GPS thật, không thu thập dữ liệu mạng, không nhúng ứng dụng vào CarPlay.
