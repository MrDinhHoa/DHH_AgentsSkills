# agent-skills

Skill dùng chung cho **Claude Code** và **Antigravity**, đồng bộ giữa các máy qua git.

| Skill | Lệnh | Việc làm |
|---|---|---|
| `bat-dau-phien` | `/bat-dau-phien [repo\|project]` | Đầu phiên: đọc `AGENTS.md`, `PROJECT_HANDOFF.md`, mọi `CLAUDE.md` (kể cả repo liên quan), kiểm tra git, báo cáo trạng thái + việc tiếp theo. Chỉ đọc. |
| `ket-thuc-phien` | `/ket-thuc-phien [ghi chú]` | Cuối phiên: cập nhật `CLAUDE.md` của project đã sửa, `PROJECT_HANDOFF.md`, `AGENTS.md` (khi đổi quy chuẩn). Không commit. |
| `sync-skills` | `/sync-skills` | Chạy lệnh `sync-skills` để cập nhật skill trên máy. |

## Cài trên máy mới (1 lần)

```powershell
git clone https://github.com/<tài-khoản>/agent-skills.git "D:\01_WORKING\00_Agent Skills"
& "D:\01_WORKING\00_Agent Skills\install.bat"
```
Có thể clone vào thư mục bất kỳ; nếu sau này **di chuyển thư mục repo**, chạy lại `install.bat` ở vị trí mới để lệnh `sync-skills` trỏ đúng chỗ.
`install` tạo lệnh `sync-skills` trong `~\.local\bin` (thêm vào PATH nếu chưa có) và cài skill lần đầu.

## Cập nhật skill

| Việc | Lệnh |
|---|---|
| Lấy bản mới về máy | `sync-skills` (git pull + cài lại) |
| Sửa skill | Sửa `skills\<tên>\SKILL.md` → `sync-skills -NoPull` để thử → commit + push |
| Thêm skill mới | Tạo `skills\<tên>\SKILL.md` (frontmatter `name`, `description`) → `sync-skills -NoPull` |
| Xóa skill | Xóa thư mục trong `skills\` → `sync-skills` tự gỡ khỏi máy |

Skill được cài vào:
- Claude Code: `~\.claude\skills\<tên>\`
- Antigravity: `~\.gemini\config\skills\<tên>\`

Mỗi skill đã cài có file `.agent-skills` đánh dấu — `sync-skills` chỉ ghi đè / gỡ những skill có dấu này, không đụng skill khác. **Không sửa bản đã cài**, vì lần sync sau sẽ bị ghi đè.

## Dùng với một project

Skill hoạt động với repo theo hệ thống tài liệu:

| File | Nội dung |
|---|---|
| `AGENTS.md` | Kiến trúc, quy chuẩn, build; mục **"Repo liên quan"** (tùy chọn) liệt kê các repo nằm cùng thư mục cha cần đọc chung; mục **"Hệ thống tài liệu"** |
| `PROJECT_HANDOFF.md` | Trạng thái, việc đã làm theo phiên, việc tiếp theo |
| `CLAUDE.md` (gốc) | `@AGENTS.md`, `@PROJECT_HANDOFF.md` |
| `<Project>/CLAUDE.md` | Chi tiết từng project, nhật ký thay đổi (mới nhất ở trên) |

Repo chưa có các file này: `/bat-dau-phien` sẽ đề nghị tạo.
