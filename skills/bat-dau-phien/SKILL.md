---
name: bat-dau-phien
description: Mở đầu phiên làm việc cho bất kỳ repo nào dùng hệ thống tài liệu AGENTS.md / PROJECT_HANDOFF.md / CLAUDE.md - đọc lại toàn bộ tài liệu (kể cả các repo liên quan), kiểm tra git, rồi tóm tắt trạng thái và việc tiếp theo. Dùng khi người dùng gõ /bat-dau-phien hoặc nói "bắt đầu phiên", "mở đầu phiên", "nắm lại dự án".
---

<!-- Nguồn: repo agent-skills. Không sửa bản đã cài trong ~/.claude/skills hoặc ~/.gemini/config/skills - sửa trong repo rồi chạy `sync-skills`. -->

# Bắt đầu phiên làm việc - nạp lại ngữ cảnh

Mục tiêu: nắm lại toàn bộ trạng thái dự án từ tài liệu trước khi làm việc. Lệnh này **chỉ đọc**: không sửa file, không build, không commit.

## Bước 0 - Xác định phạm vi

1. **Repo hiện tại** = `git rev-parse --show-toplevel` tại thư mục làm việc. Không phải git repo → dùng thư mục làm việc.
2. **Repo liên quan**: nếu `AGENTS.md` của repo hiện tại có mục **"Repo liên quan"**, lấy danh sách tên repo trong đó và tìm từng repo theo thứ tự ở mục "Tìm repo liên quan" bên dưới.
3. **Tham số** sau lệnh (nếu có):
   - Tên repo → chỉ đọc repo đó.
   - Tên project / thư mục → chỉ đọc `CLAUDE.md` của project đó + `AGENTS.md`, `PROJECT_HANDOFF.md` của repo chứa nó.

## Bước 1 - Đọc tài liệu

Với mỗi repo trong phạm vi, đọc **toàn bộ nội dung** (không đọc lướt):
1. `AGENTS.md` - quy chuẩn kiến trúc, tham chiếu, lệnh build, quy ước.
2. `PROJECT_HANDOFF.md` - trạng thái, việc đã làm, việc tiếp theo.
3. Mọi file `CLAUDE.md` trong repo, tìm theo mẫu `**/CLAUDE.md` (bỏ qua `bin`, `obj`, `node_modules`, `.vs`, `packages`, `dist`, `build`). Không dùng danh sách cố định - project mới thêm cũng phải được đọc.

Các file độc lập nhau → đọc song song nếu công cụ cho phép.

**Repo chưa có hệ thống tài liệu** (thiếu cả `AGENTS.md` lẫn `PROJECT_HANDOFF.md`): đọc `README*` và cấu trúc thư mục cấp 1-2 để tóm tắt; trong báo cáo đề nghị thiết lập hệ thống tài liệu (mục "Thiết lập" bên dưới) - **chỉ làm khi người dùng đồng ý**.

## Bước 2 - Kiểm tra git

Với mỗi repo: `git status --short`, `git log --oneline -5`, `git branch --show-current`.
Ghi nhận: thay đổi chưa commit, commit gần nhất, và commit mới hơn ngày ghi trong `PROJECT_HANDOFF.md` (→ báo tài liệu có thể đã lỗi thời).

## Bước 3 - Báo cáo ngắn

Tiếng Việt, gọn trong một màn hình:
1. **Trạng thái từng repo**: nhánh, ngày cập nhật handoff, trạng thái build/chạy theo tài liệu, file chưa commit (nhóm theo project).
2. **Bảng project**: tên - trạng thái (ổn định / đang phát triển / dở dang / lỗi build) - vấn đề chính, lấy từ mục "Mục đích & trạng thái" và "Vấn đề đã biết" của từng `CLAUDE.md`.
3. **Việc cần làm tiếp theo**: gộp từ `PROJECT_HANDOFF.md` và mục "Việc tiếp theo" của các `CLAUDE.md`, sắp theo ưu tiên (lỗi build / lỗi chặn chức năng trước).
4. **Điểm cần chú ý**: tài liệu mâu thuẫn nhau, tài liệu lỗi thời so với git, việc ghi "chưa kiểm thử", repo liên quan không tìm thấy.

Kết thúc bằng một câu hỏi: hôm nay muốn làm việc gì (gợi ý 2-3 việc ưu tiên nhất).

## Tìm repo liên quan (đường dẫn có thể khác nhau giữa các máy)

Với mỗi tên repo trong mục "Repo liên quan":
1. `<thư mục cha của repo hiện tại>\<tên>` - nếu tồn tại thì dùng.
2. Bảng ánh xạ riêng của máy `~\.agent-skills\paths.json` (không đồng bộ giữa các máy):
   ```json
   { "repos": { "01_PiExcel": "E:\\Work\\01_PiExcel" } }
   ```
   Có khóa trùng tên và thư mục tồn tại → dùng.
3. Không tìm thấy → hỏi người dùng đường dẫn (hoặc bỏ qua repo đó và ghi chú trong báo cáo). Người dùng cho đường dẫn → đề nghị lưu vào `paths.json` (tạo file nếu chưa có, giữ nguyên các khóa khác) để lần sau tự tìm được.

Không ghi đường dẫn tuyệt đối của máy vào `AGENTS.md` / tài liệu dùng chung - chỉ ghi **tên** repo.

## Thiết lập hệ thống tài liệu (chỉ khi người dùng đồng ý)

| File | Nội dung | Khi nào cập nhật |
|---|---|---|
| `AGENTS.md` (gốc repo) | Kiến trúc, quy chuẩn, tham chiếu, lệnh build, mục "Repo liên quan" (nếu có), mục "Hệ thống tài liệu" (bảng này) | Khi đổi kiến trúc / quy chuẩn / đường dẫn / build |
| `PROJECT_HANDOFF.md` (gốc repo) | Thời gian cập nhật, trạng thái build, công việc theo phiên, việc tiếp theo | Mỗi phiên |
| `CLAUDE.md` (gốc repo) | `@AGENTS.md`, `@PROJECT_HANDOFF.md` + ghi chú ngắn cho Claude Code | Hiếm khi |
| `<Project>/CLAUDE.md` | Mục đích & trạng thái, cấu trúc & luồng, thuật toán, vấn đề đã biết, build, việc tiếp theo, nhật ký thay đổi (mới nhất ở trên) | Mỗi phiên có sửa project đó |

## Lưu ý

- Chỉ tóm tắt, không chép nguyên văn tài liệu.
- Ghi nhớ nội dung đã đọc cho cả phiên; khi người dùng chọn project, không đọc lại `CLAUDE.md` của project đó trừ khi file thay đổi.
