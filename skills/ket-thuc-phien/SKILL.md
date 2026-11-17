---
name: ket-thuc-phien
description: Cập nhật tài liệu cuối phiên làm việc cho bất kỳ repo nào dùng hệ thống tài liệu AGENTS.md / PROJECT_HANDOFF.md / CLAUDE.md - CLAUDE.md của từng project đã sửa, PROJECT_HANDOFF.md, và AGENTS.md khi đổi quy chuẩn. Dùng khi người dùng gõ /ket-thuc-phien hoặc nói "kết thúc phiên", "bàn giao phiên", "cập nhật handoff".
---

<!-- Nguồn: repo DHH_AgentsSkills. Không sửa bản đã cài trong ~/.claude/skills hoặc ~/.gemini/config/skills - sửa trong repo rồi chạy `sync-skills`. -->

# Kết thúc phiên làm việc - cập nhật tài liệu

Mục tiêu: ghi lại những gì phiên này đã làm vào đúng file tài liệu, theo bảng phân vai trong mục "Hệ thống tài liệu" của `AGENTS.md`.
Nếu người dùng ghi thêm nội dung sau lệnh (vd. kết quả test thủ công) → đưa vào tài liệu tương ứng.

## Bước 1 - Xác định phạm vi

1. **Repo hiện tại** = `git rev-parse --show-toplevel`. **Repo liên quan** = danh sách tên trong mục "Repo liên quan" của `AGENTS.md` (nếu có); tìm đường dẫn theo cùng thứ tự như skill `bat-dau-phien` (mục "Tìm repo liên quan": thư mục cha chung → `~\.agent-skills\paths.json` → hỏi người dùng). Không ghi đường dẫn tuyệt đối của máy vào tài liệu dùng chung.
2. Với từng repo: `git status --short` và `git diff --stat` (cả staged).
3. Kết hợp git với những gì đã làm trong hội thoại - kể cả việc chỉ rà soát / phát hiện lỗi mà không sửa code, và thay đổi đã commit giữa phiên.
4. Ánh xạ mỗi thay đổi → project chứa nó (thư mục có file dự án: `.csproj`, `package.json`, `pyproject.toml`…). Nếu `AGENTS.md` / `CLAUDE.md` quy định một nhóm project dùng chung một `CLAUDE.md` → cập nhật file chung đó.
5. Nếu phiên không thay đổi gì đáng ghi → báo người dùng và dừng.
6. Repo chưa có `AGENTS.md` / `PROJECT_HANDOFF.md` → hỏi người dùng có muốn tạo không (cấu trúc xem skill `bat-dau-phien`, mục "Thiết lập"); không tự tạo.

## Bước 2 - Cập nhật `CLAUDE.md` của từng project đã sửa

Đọc file trước khi sửa. Tìm mục theo **tên** (số thứ tự mục có thể khác nhau giữa các file). Chỉ sửa mục liên quan:
- **Mục đích & trạng thái**: cập nhật nếu trạng thái thay đổi (hết lỗi build, thêm chức năng, đã/chưa kiểm thử).
- **Cấu trúc / luồng / thuật toán**: cập nhật nếu thêm/bỏ file, class, đổi luồng, đổi hằng số quan trọng.
- **Vấn đề đã biết**: xóa mục đã sửa xong; thêm lỗi / giới hạn mới phát hiện.
- **Việc tiếp theo**: bỏ việc đã xong, thêm việc mới.
- **Nhật ký thay đổi**: thêm 1 dòng **ở đầu danh sách** (mới nhất ở trên): `- dd/mm/yyyy: nội dung ngắn` (ngày hôm nay).

Project chưa có `CLAUDE.md` → tạo mới theo cấu trúc của các `CLAUDE.md` khác trong cùng repo.

## Bước 3 - Cập nhật `PROJECT_HANDOFF.md` của repo

- Sửa dòng **Thời gian cập nhật** thành ngày hôm nay.
- Cập nhật **trạng thái build** nếu có build trong phiên (ghi đúng kết quả thực tế, không phỏng đoán).
- Thêm một mục công việc của phiên (tiêu đề có ngày + tên agent: Claude Code / Antigravity), tóm tắt ngắn, trỏ sang `CLAUDE.md` project cho chi tiết - không chép lại chi tiết.
- Cập nhật **Việc cần làm tiếp theo**: bỏ việc đã xong, thêm/sắp xếp lại việc mới.

## Bước 4 - `AGENTS.md` (chỉ khi cần)

Chỉ sửa khi phiên có: thêm/bỏ/đổi tên project hoặc solution, đổi đường dẫn tham chiếu chuẩn, đổi quy tắc / công cụ build, đổi quy ước lập trình, thêm/bỏ repo liên quan. Nếu không → không động vào.

## Bước 5 - Báo cáo

Liệt kê ngắn gọn từng file đã cập nhật và nội dung chính. **Không commit / push** trừ khi người dùng yêu cầu; nếu muốn, hỏi một dòng ở cuối.

## Lưu ý

- Viết tiếng Việt, ngắn gọn, giữ đúng định dạng đang có của từng file.
- Không chép nội dung giữa các file; file chung chỉ tóm tắt và tham chiếu.
- Ghi đúng sự thật: việc chưa kiểm thử thì ghi "chưa kiểm thử"; build lỗi thì ghi lỗi.
