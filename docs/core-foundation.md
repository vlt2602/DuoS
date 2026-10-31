# DuoSCore - Huong dan kiem thu 2C

## Gioi han cua ban preview
- Theo doi ket noi va ngat ket noi man hinh ngoai, KHONG phat hien CarPlay rieng.
- Mac dinh khong theo doi man hinh (enabled = false).
- Settings/DuoS co cong tac 'Theo doi man hinh ngoai'.
- Khi bat, SpringBoard nhan Darwin Notification va dang ky UIScreenDidConnect/Disconnect.
- Khi tat, huy dang ky va xoa trang thai; khong polling, khong timer.
- Ho tro model 50/50 va 65/35 va phep tinh frame; chua co split screen UI.
- Khong dung private hooks, khong inject apps, khong lay GPS, khong network.
- Khong khang dinh an toan Runtime cho den khi kiem thu tren iOS 15.8.8.

## Quy trinh review
1. Tren GitHub, mo PR #1 -> Checks; doi chieu dau xanh.
2. Kiem tra buoc Verify two-pane geometry va Validate repository.
3. Tranh cai dat tren iPhone chinh truoc khi co backup va ke hoach khoi phuc.
4. Neu can thu tren xe, de xe do an toan; khong tuong tac khi dieu khien.
5. Khong merge PR vao main khi chua thong nhat ket qua thu va kha nang rollback.
