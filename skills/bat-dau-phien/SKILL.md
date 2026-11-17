---
name: bat-dau-phien
description: Mở đầu phiên làm việc cho bất kỳ repo nào dùng hệ thống tài liệu AGENTS.md / PROJECT_HANDOFF.md / CLAUDE.md. Tự động quét và liệt kê danh sách Solution (.sln/.slnx) hoặc Project đánh số để người dùng chọn phạm vi trước khi quyết định. Dùng khi gõ /bat-dau-phien [solution|project|số].
---

<!-- Nguồn: repo DHH_AgentsSkills. Không sửa bản đã cài trong ~/.claude/skills hoặc ~/.gemini/config/skills - sửa trong repo rồi chạy `sync-skills`. -->

# Bắt đầu phiên làm việc - nạp lại ngữ cảnh

Mục tiêu: nắm lại toàn bộ trạng thái dự án từ tài liệu trước khi làm việc. Lệnh này **chỉ đọc**: không sửa file, không build, không commit.

## Bước 0 - Quét và xác định danh sách Solution / Project

1. **Repo / Workspace hiện tại** = `git rev-parse --show-toplevel` tại thư mục làm việc. Không phải git repo → dùng thư mục làm việc hiện tại.
2. **Repo liên quan**: nếu `AGENTS.md` có mục **"Repo liên quan"**, lấy danh sách tên repo theo mục "Tìm repo liên quan" bên dưới.
3. **Quét danh sách Solution & Project trong phạm vi**:
   - **Có Solution (`*.sln`, `*.slnx`)**: Quét tất cả Solution và các project bên trong (`.csproj`, v.v.), bỏ qua thư mục build/tạm (`bin`, `obj`, `.vs`). Phân cấp `[1] Solution A` -> `1.1 Proj A1`, `1.2 Proj A2`...
   - **Không có Solution**: Quét tất cả các project con (thư mục có `.git`, `package.json`, `pyproject.toml`, `requirements.txt`, hoặc các thư mục con cấp 1 chứa code). Đánh số thứ tự `[1] Proj 1`, `[2] Proj 2`... kèm tùy chọn `[A] Toàn bộ workspace`.

## Bước 1 - Điều hướng theo tham số người dùng

- **Trường hợp A: Người dùng đã truyền tham số** (ví dụ `/bat-dau-phien 1`, `/bat-dau-phien 1 2`, `/bat-dau-phien <tên_project>` hoặc `/bat-dau-phien <tên_solution>`):
  - Xác định đúng phạm vi được chọn (Solution hoặc Project).
  - Đọc `AGENTS.md`, `PROJECT_HANDOFF.md` ở gốc + các `CLAUDE.md` thuộc phạm vi đó.
  - Chuyển sang Bước 2 & 3 để báo cáo trạng thái chi tiết cho phạm vi đó.

- **Trường hợp B: Không truyền tham số (`/bat-dau-phien`)**:
  - **Nếu chỉ có đúng 1 project đơn lẻ duy nhất**: Tự động nạp toàn bộ và báo cáo chi tiết.
  - **Nếu có nhiều Solution / Project**:
    1. Kiểm tra nhanh Git status chung (`git status --short`).
    2. **In ra MENU DANH SÁCH SOLUTION & PROJECT ĐÁNH SỐ** (tương tự giao diện `csbuild`):
       ```text
       ============================================================
        DANH SÁCH DỰ ÁN TRONG WORKSPACE
       ============================================================
       [1] <Tên Solution 1 hoặc Project 1> - <Trạng thái nhanh/Mô tả>
           ├── 1.1 <Project con>
           └── 1.2 <Project con>
       [2] <Tên Solution 2 hoặc Project 2> - <Trạng thái nhanh/Mô tả>
       [A] Toàn bộ workspace (Nạp tất cả)
       ============================================================
       ```
    3. **Dừng lại và hỏi người dùng**: Mời người dùng chọn số thứ tự (ví dụ gõ `1`, `1.2`, hoặc `A`) hoặc tên project muốn bắt đầu phiên. (Không nạp sâu tất cả tài liệu ngay để tránh tràn ngữ cảnh khi chưa có quyết định).

## Bước 2 - Đọc tài liệu theo phạm vi đã chọn

Khi phạm vi đã được xác định:
1. `AGENTS.md` - quy chuẩn kiến trúc, tham chiếu, lệnh build, quy ước.
2. `PROJECT_HANDOFF.md` - trạng thái, việc đã làm, việc tiếp theo.
3. Các file `CLAUDE.md` thuộc phạm vi đã chọn (bỏ qua `bin`, `obj`, `node_modules`, `.vs`, `packages`, `dist`, `build`).

**Repo chưa có hệ thống tài liệu** (thiếu cả `AGENTS.md` lẫn `PROJECT_HANDOFF.md`): đọc `README*` để tóm tắt; trong báo cáo đề nghị thiết lập hệ thống tài liệu - **chỉ làm khi người dùng đồng ý**.

## Bước 3 - Kiểm tra git & Báo cáo ngắn

1. Kiểm tra Git trong phạm vi: `git status --short`, `git log --oneline -5`, `git branch --show-current`.
2. Báo cáo ngắn gọn trong 1 màn hình:
   - **Phạm vi đang nạp**: `[Solution: <tên>]` hoặc `[Project: <tên>]` hoặc `[Toàn bộ]`.
   - **Trạng thái Git & Build**: Nhánh, commit gần nhất, file chưa commit.
   - **Vấn đề đã biết & Việc tiếp theo**: Rút từ `CLAUDE.md` và `PROJECT_HANDOFF.md`.
   - **Gợi ý việc ưu tiên cần làm hôm nay**.

## Tìm repo liên quan (đường dẫn có thể khác nhau giữa các máy)

Với mỗi tên repo trong mục "Repo liên quan":
1. `<thư mục cha của repo hiện tại>\<tên>` - nếu tồn tại thì dùng.
2. Bảng ánh xạ riêng của máy `~\.agent-skills\paths.json`:
   ```json
   { "repos": { "01_PiExcel": "E:\\Work\\01_PiExcel" } }
   ```
   Có khóa trùng tên và thư mục tồn tại → dùng.
3. Không tìm thấy → hỏi người dùng đường dẫn (hoặc bỏ qua và ghi chú trong báo cáo).

## Thiết lập hệ thống tài liệu (chỉ khi người dùng đồng ý)

| File | Nội dung | Khi nào cập nhật |
|---|---|---|
| `AGENTS.md` (gốc repo) | Kiến trúc, quy chuẩn, tham chiếu, lệnh build, mục "Repo liên quan", mục "Hệ thống tài liệu" | Khi đổi kiến trúc / quy chuẩn / đường dẫn / build |
| `PROJECT_HANDOFF.md` (gốc repo) | Thời gian cập nhật, trạng thái build, công việc theo phiên, việc tiếp theo | Mỗi phiên |
| `CLAUDE.md` (gốc repo) | `@AGENTS.md`, `@PROJECT_HANDOFF.md` + ghi chú ngắn cho Claude Code | Hiếm khi |
| `<Project>/CLAUDE.md` | Mục đích & trạng thái, cấu trúc & luồng, thuật toán, vấn đề đã biết, build, việc tiếp theo, nhật ký thay đổi | Mỗi phiên có sửa project đó |

## Lưu ý

- Chỉ tóm tắt, không chép nguyên văn tài liệu.
- Giữ menu lựa chọn trực quan, dễ thao tác bằng cách gõ số thứ tự.
