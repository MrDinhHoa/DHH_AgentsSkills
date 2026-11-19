---
name: ket-thuc-phien
description: Cập nhật tài liệu cuối phiên làm việc cho bất kỳ repo nào dùng hệ thống tài liệu AGENTS.md / PROJECT_HANDOFF.md / CLAUDE.md. Hỗ trợ chọn project theo số thứ tự hoặc tên trước khi cập nhật tài liệu. Dùng khi gõ /ket-thuc-phien [số|project] [ghi chú].
---

<!-- Nguồn: repo DHH_AgentsSkills. Không sửa bản đã cài trong ~/.claude/skills hoặc ~/.gemini/config/skills - sửa trong repo rồi chạy `sync-skills`. -->

# Kết thúc phiên làm việc - cập nhật tài liệu

Mục tiêu: ghi lại những gì phiên này đã làm vào đúng file tài liệu, theo bảng phân vai trong mục "Hệ thống tài liệu" của `AGENTS.md`.

## Bước 1 - Xác định phạm vi & Lựa chọn Project

1. **Repo / Workspace hiện tại** = `git rev-parse --show-toplevel`. Nếu không phải git repo → dùng thư mục làm việc hiện tại.
2. **Kiểm tra thay đổi**: `git status --short` và `git diff --stat` (cả staged và untracked).
3. **Phát hiện các project liên quan trong phiên**:
   - Ánh xạ các file thay đổi hoặc các project đã thảo luận/chỉnh sửa trong phiên sang từng project cụ thể (thư mục có `.csproj`, `package.json`, `pyproject.toml`, `.git`, hoặc thư mục con cấp 1).
4. **Điều hướng lựa chọn**:
   - **Đã truyền tham số project / số thứ tự** (ví dụ `/ket-thuc-phien 1`, `/ket-thuc-phien "Structure MCP" "Đã fix lỗi"`):
     -> Áp dụng cập nhật cho đúng project được chỉ định.
   - **Không truyền tham số (`/ket-thuc-phien`)**:
     + Nếu chỉ có duy nhất 1 project có thay đổi trong phiên: Tự động cập nhật cho project đó.
     + Nếu có nhiều project có thay đổi (hoặc workspace đa dự án chưa rõ cập nhật vào đâu):
       **Liệt kê menu đánh số các project để người dùng chọn trước khi cập nhật**:
       ```text
       ============================================================
        CHỌN DỰ ÁN CẦN CẬP NHẬT TÀI LIỆU CUỐI PHIÊN
       ============================================================
       [1] <Project A> - (Có 3 file thay đổi)
       [2] <Project B> - (Có 1 file thay đổi)
       [A] Cập nhật tất cả các project trên
       ============================================================
       ```
       Dừng lại hỏi người dùng chọn số thứ tự (ví dụ gõ `1`, `2` hoặc `A`).

5. Nếu phiên hoàn toàn không có thay đổi nào đáng ghi nhận → báo người dùng và dừng.
6. Repo chưa có `AGENTS.md` / `PROJECT_HANDOFF.md` → hỏi người dùng có muốn tạo không; không tự tạo.

## Bước 2 - Cập nhật `CLAUDE.md` của từng project được chọn

Đọc file trước khi sửa. Chỉ sửa mục liên quan:
- **Mục đích & trạng thái**: cập nhật nếu trạng thái thay đổi (hết lỗi build, thêm chức năng, đã/chưa kiểm thử).
- **Cấu trúc / luồng / thuật toán**: cập nhật nếu thêm/bỏ file, class, đổi luồng, đổi hằng số quan trọng.
- **Vấn đề đã biết**: xóa mục đã sửa xong; thêm lỗi / giới hạn mới phát hiện.
- **Việc tiếp theo**: bỏ việc đã xong, thêm việc mới.
- **Nhật ký thay đổi**: thêm 1 dòng **ở đầu danh sách** (mới nhất ở trên): `- dd/mm/yyyy: nội dung ngắn` (ngày hôm nay).

Project chưa có `CLAUDE.md` → tạo mới theo cấu trúc của các `CLAUDE.md` khác trong cùng repo.

## Bước 3 - Cập nhật `PROJECT_HANDOFF.md` của repo

- Sửa dòng **Thời gian cập nhật** thành ngày hôm nay.
- Cập nhật **trạng thái build** nếu có build trong phiên.
- Thêm một mục công việc của phiên (tiêu đề có ngày + tên agent: Claude Code / Antigravity), tóm tắt ngắn, trỏ sang `CLAUDE.md` project cho chi tiết.
- **Lưu trữ phiên cũ**: nếu `AGENTS.md` (hoặc đầu `PROJECT_HANDOFF.md`) có quy ước giới hạn số phiên / file lưu trữ (vd. giữ 3 phiên gần nhất, phiên cũ chuyển sang `HANDOFF_ARCHIVE.md`), áp dụng ngay sau khi thêm mục phiên mới: chuyển **nguyên văn** các phiên vượt giới hạn (cũ nhất trước) sang cuối file lưu trữ. Không có quy ước → giữ nguyên.
- Cập nhật **Việc cần làm tiếp theo**: bỏ việc đã xong, thêm/sắp xếp lại việc mới.

## Bước 4 - `AGENTS.md` (chỉ khi cần)

Chỉ sửa khi phiên có: thêm/bỏ/đổi tên project hoặc solution, đổi đường dẫn tham chiếu chuẩn, đổi quy tắc / công cụ build, đổi quy ước lập trình, thêm/bỏ repo liên quan. Nếu không → giữ nguyên.

## Bước 5 - Báo cáo

Liệt kê ngắn gọn từng file đã cập nhật và nội dung chính. **Không commit / push** trừ khi người dùng yêu cầu.

## Lưu ý

- Viết tiếng Việt, ngắn gọn, giữ đúng định dạng đang có của từng file.
- Ghi đúng sự thật: việc chưa kiểm thử thì ghi "chưa kiểm thử"; build lỗi thì ghi lỗi.
- Đảm bảo người dùng luôn kiểm soát được tài liệu của project nào đang được cập nhật.
