## Skill & quy tắc dùng chung - repo `DHH_AgentsSkills`

- Mọi skill dùng chung (vd. `bat-dau-phien`, `ket-thuc-phien`, `sync-skills`) và khối quy tắc này có **nguồn duy nhất** là repo `DHH_AgentsSkills` (GitHub private `MrDinhHoa/DHH_AgentsSkills`). Vị trí trên máy này: `{{AGENT_SKILLS_DIR}}`.
- Đường dẫn khác nhau giữa các máy: **không ghi đường dẫn tuyệt đối của máy** vào skill, quy tắc hay tài liệu dùng chung. Repo liên quan tìm theo thư mục cha chung, nếu không có thì tra bảng ánh xạ riêng của máy `~\.agent-skills\paths.json` (không đồng bộ, mỗi máy tự có).
- Khi **sửa** hoặc **thêm** skill dùng chung:
  1. Sửa / tạo `skills\<tên>\SKILL.md` trong repo đó (frontmatter `name`, `description`; viết trung lập, dùng được cho cả Claude Code và Antigravity; không ghi đường dẫn cố định của một project).
  2. Cập nhật bảng skill trong `README.md` của repo nếu thêm/bỏ skill.
  3. Chạy `sync-skills -NoPull` để cài vào `~\.claude\skills` và `~\.gemini\config\skills`.
  4. Báo người dùng; chỉ commit / push khi được yêu cầu.
- Khi **sửa quy tắc chung** này: sửa `rules\agent-skills-rules.md` trong repo rồi chạy `sync-skills -NoPull` (chèn lại vào `~\.claude\CLAUDE.md` và `~\.gemini\config\AGENTS.md`).
- **Không** sửa bản đã cài (`~\.claude\skills`, `~\.gemini\config\skills`, khối giữa dấu `agent-skills` trong `CLAUDE.md` / `AGENTS.md` toàn cục) - sẽ bị ghi đè khi sync.
- **Không** đặt bản skill dùng chung trong từng project (`.claude\skills`, `.claude\commands`, `.agents\skills`) - gây trùng tên.
- Skill chỉ dành riêng cho một project → hỏi người dùng nên đặt trong project đó hay đưa vào repo `DHH_AgentsSkills`.
