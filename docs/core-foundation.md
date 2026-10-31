# DuoSCore – Nen tang module A

Trang thai: ban thu nghiem, chua chia man hinh.

- Nap trong SpringBoard theo filter hien co.
- Dung UIScreenDidConnectNotification / UIScreenDidDisconnectNotification de theo doi man hinh ngoai.
- Khong polling, khong timer, khong network, khong hook API rieng tu.
- Duy tri mo hinh bo cuc 50/50 hoac 65/35 chi trong RAM.
- Chua khoi tao FBScene, chua giu app nen, chua lay/chuyen tiep cam ung.
- Man hinh ngoai khong dong nghia phien CarPlay. Can kiem thu CarPlay tren may that.
- Khong su dung khi dang dieu khien xe.

## Kiem tra
1. Pull request build tren GitHub Actions.
2. Kiem tra log compile va dong goi rootless.
3. Khong cai len iPhone cho toi khi da thiet ke phep thu va rollback an toan.
