# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repo này là gì

Nguồn duy nhất của skill và quy tắc dùng chung cho **Claude Code** và **Antigravity** trên nhiều máy Windows của người dùng. Không có build / lint / test - "chạy thử" = cài skill vào máy bằng `sync-skills` và mở phiên mới.

## Lệnh

| Việc | Lệnh |
|---|---|
| Cài skill + chèn quy tắc từ bản đang sửa (không pull) | `sync-skills -NoPull` |
| Pull + cài | `sync-skills` (bỏ qua pull nếu repo có thay đổi chưa commit) |
| Ghi đè cả skill trùng tên không do sync cài | `sync-skills -NoPull -Force` |
| Cài lệnh `sync-skills` lần đầu trên máy | `install.bat` |
| Kiểm tra máy (chỉ đọc) | `kiem-tra-may.bat` → kết quả `kiem-tra-may.txt` trên Desktop |
| Cài Node portable, Gemini CLI, ripgrep, `codex`, `agy` (không cần admin) | `cai-agent-tools.bat`; thử không đụng hệ thống: `cai-agent-tools.ps1 -ForceNode -NoPathChange -NodeDir <thư mục tạm>` |
| Kiểm cú pháp một script PowerShell | `[Management.Automation.Language.Parser]::ParseFile('<file>.ps1',[ref]$null,[ref]$e); $e.Count` |

`sync-skills` là `~\.local\bin\sync-skills.cmd` do `install.ps1` tạo, trỏ về `sync-skills.ps1` ở vị trí repo hiện tại (dời repo → chạy lại `install.bat`).

## Kiến trúc

- `skills\<tên>\SKILL.md` (frontmatter `name`, `description`, tùy chọn `argument-hint`) + thư mục phụ (`references`, `scripts`, `assets`...). Thư mục nào không có `SKILL.md` thì bị bỏ qua.
- `sync-skills.ps1`:
  1. `git pull --ff-only` (trừ `-NoPull`). Nếu chính `sync-skills.ps1` vừa đổi sau pull → tự chạy lại bằng bản mới; nếu `install.ps1` đổi → nhắc chạy lại `install.bat`.
  2. Copy nguyên thư mục từng skill vào `~\.claude\skills\` và `~\.gemini\config\skills\`, ghi file đánh dấu `.agent-skills` vào mỗi skill đã cài. Chỉ ghi đè / gỡ skill **có** file đánh dấu; skill bị xóa khỏi repo sẽ tự gỡ khỏi máy.
  3. Chèn `rules\agent-skills-rules.md` vào `~\.claude\CLAUDE.md` và `~\.gemini\config\AGENTS.md`, chỉ thay phần giữa `<!-- BEGIN agent-skills ... -->` / `<!-- END agent-skills -->`; placeholder `{{AGENT_SKILLS_DIR}}` được thay bằng vị trí repo thật.
- Bản đã cài (`~\.claude\skills`, `~\.gemini\config\skills`, khối giữa 2 dấu trong file toàn cục) **bị ghi đè mỗi lần sync** - luôn sửa trong repo rồi `sync-skills -NoPull`.
- Đường dẫn khác nhau giữa các máy: không ghi đường dẫn tuyệt đối vào skill / quy tắc / tài liệu. Repo liên quan tìm theo thư mục cha chung, rồi `~\.agent-skills\paths.json` (riêng từng máy, không nằm trong repo).
- Skill `dieu-phoi-agent` gọi agent phụ bằng CLI: `codex` (shim `skills\dieu-phoi-agent\scripts\codex.cmd` tìm `codex.exe` trong extension `openai.chatgpt` của Antigravity / VS Code, được copy vào `~\.local\bin`), `agy` (Antigravity CLI, gói Google AI Pro), `gemini` (chỉ còn dùng với API key). Giới hạn đã kiểm chứng của từng CLI ghi trong `SKILL.md` của skill đó.

## Quy ước

- **Thêm / bỏ skill → cập nhật bảng skill trong `README.md`** (nhóm theo mục, cột Lệnh / Việc làm; skill lấy từ nguồn ngoài ghi `Nguồn: <owner/repo>`).
- `SKILL.md` viết tiếng Việt, trung lập cho cả Claude Code lẫn Antigravity, không gắn với một project cụ thể.
- Script `.ps1` / `.cmd` / `.bat`: **chỉ dùng ký tự ASCII** (chuỗi tiếng Việt viết không dấu). Windows PowerShell 5.1 đọc `.ps1` UTF-8 không BOM theo bảng mã ANSI → có dấu sẽ hỏng. Đích chạy là Windows PowerShell 5.1, máy công ty không có quyền admin, tên user có thể chứa dấu cách - mọi cài đặt phải ở phạm vi user.
- Bẫy PowerShell 5.1 đã gặp trong repo: `Invoke-RestMethod` trả mảng JSON không tách phần tử trong pipeline (gán biến trước rồi mới lọc); `$ErrorActionPreference='Stop'` + `2>&1` biến mọi dòng stderr của chương trình ngoài thành lỗi dừng; `>` ghi file UTF-16; ghi PATH người dùng phải qua registry (`DoNotExpandEnvironmentNames` + kiểu `ExpandString`) để giữ các mục `%VAR%`.
- Wrapper `.bat` theo mẫu `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0<script>.ps1" %*` rồi `pause`.
- Chỉ commit / push khi người dùng yêu cầu.
