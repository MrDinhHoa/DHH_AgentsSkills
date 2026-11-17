# DHH_AgentsSkills

Skill và quy tắc dùng chung cho **Claude Code** và **Antigravity**, đồng bộ giữa các máy qua git.

```
skills\<tên>\SKILL.md          ← các skill
rules\agent-skills-rules.md    ← quy tắc chung (cách quản lý skill), chèn vào file hướng dẫn toàn cục
sync-skills.ps1                ← git pull + cài skill + chèn quy tắc
install.bat / install.ps1      ← cài lệnh `sync-skills` (1 lần mỗi máy)
```

| Skill | Lệnh | Việc làm |
|---|---|---|
| `bat-dau-phien` | `/bat-dau-phien [solution\|project\|số]` | Đầu phiên: đọc tài liệu (`AGENTS.md`, `PROJECT_HANDOFF.md`, các `CLAUDE.md`), kiểm tra git, báo cáo trạng thái + việc tiếp theo. Hỗ trợ chọn phạm vi theo Solution (.sln/.slnx), từng Project hoặc số thứ tự (tương tự csbuild). Chỉ đọc. |
| `ket-thuc-phien` | `/ket-thuc-phien [số\|project] [ghi chú]` | Cuối phiên: cập nhật `CLAUDE.md` của project đã sửa, `PROJECT_HANDOFF.md`, `AGENTS.md`. Hỗ trợ chọn project theo số thứ tự hoặc tên trước khi cập nhật. Không commit. |
| `sync-skills` | `/sync-skills` | Chạy lệnh `sync-skills` để cập nhật skill trên máy. |

## Cài trên máy mới (1 lần)

```powershell
git clone https://github.com/MrDinhHoa/DHH_AgentsSkills.git "D:\01_WORKING\00_Agent Skills"
& "D:\01_WORKING\00_Agent Skills\install.bat"
```
Có thể clone vào thư mục bất kỳ; nếu sau này **di chuyển thư mục repo**, chạy lại `install.bat` ở vị trí mới để lệnh `sync-skills` trỏ đúng chỗ.
`install` tạo lệnh `sync-skills` trong `~\.local\bin` (thêm vào PATH nếu chưa có), cài skill và chèn quy tắc chung lần đầu.

## Cập nhật skill

| Việc | Lệnh |
|---|---|
| Lấy bản mới về máy | `sync-skills` (git pull + cài lại) |
| Sửa skill | Sửa `skills\<tên>\SKILL.md` → `sync-skills -NoPull` để thử → commit + push |
| Thêm skill mới | Tạo `skills\<tên>\SKILL.md` (frontmatter `name`, `description`) → `sync-skills -NoPull` |
| Xóa skill | Xóa thư mục trong `skills\` → `sync-skills` tự gỡ khỏi máy |
| Sửa chính `sync-skills.ps1` | Sửa → commit + push. Máy khác chỉ cần chạy `sync-skills`: script `git pull` về, thấy chính nó thay đổi thì **tự chạy lại bằng bản mới** ngay trong lần đó |
| Sửa `install.ps1` | Máy khác chạy `sync-skills` sẽ được nhắc chạy lại `install.bat` (chỉ cần khi đổi cách tạo lệnh / PATH) |

Skill được cài vào:
- Claude Code: `~\.claude\skills\<tên>\`
- Antigravity: `~\.gemini\config\skills\<tên>\`

Mỗi skill đã cài có file `.agent-skills` đánh dấu — `sync-skills` chỉ ghi đè / gỡ những skill có dấu này, không đụng skill khác. **Không sửa bản đã cài**, vì lần sync sau sẽ bị ghi đè.

## Quy tắc chung

Nội dung `rules\agent-skills-rules.md` được chèn vào file hướng dẫn toàn cục của từng công cụ (nạp ở mọi project):
- Claude Code: `~\.claude\CLAUDE.md`
- Antigravity: `~\.gemini\config\AGENTS.md`

Khối được bao giữa `<!-- BEGIN agent-skills ... -->` và `<!-- END agent-skills -->`. Mỗi lần sync chỉ thay phần giữa 2 dấu này — **nội dung khác bạn tự viết trong 2 file đó được giữ nguyên**. File chưa có thì được tạo mới.
Sửa quy tắc: sửa `rules\agent-skills-rules.md` → `sync-skills -NoPull` → commit + push.

## Đường dẫn khác nhau giữa các máy

| Thứ | Cách xử lý |
|---|---|
| Vị trí repo `DHH_AgentsSkills` | Clone ở đâu cũng được → chạy `install.bat` tại đó. Lệnh `sync-skills` nhớ vị trí; khối quy tắc tự điền vị trí thật (`{{AGENT_SKILLS_DIR}}`). |
| Repo liên quan của một project | `AGENTS.md` chỉ ghi **tên** repo. Skill tìm: thư mục cha chung → `~\.agent-skills\paths.json` → hỏi và đề nghị lưu. |
| `~\.agent-skills\paths.json` | Bảng ánh xạ **riêng từng máy**, không nằm trong repo: `{ "repos": { "<tên repo>": "<đường dẫn>" } }` |

## Dùng với một project

Skill hoạt động với repo theo hệ thống tài liệu:

| File | Nội dung |
|---|---|
| `AGENTS.md` | Kiến trúc, quy chuẩn, build; mục **"Repo liên quan"** (tùy chọn) liệt kê các repo nằm cùng thư mục cha cần đọc chung; mục **"Hệ thống tài liệu"** |
| `PROJECT_HANDOFF.md` | Trạng thái, việc đã làm theo phiên, việc tiếp theo |
| `CLAUDE.md` (gốc) | `@AGENTS.md`, `@PROJECT_HANDOFF.md` |
| `<Project>/CLAUDE.md` | Chi tiết từng project, nhật ký thay đổi (mới nhất ở trên) |

Repo chưa có các file này: `/bat-dau-phien` sẽ đề nghị tạo.
