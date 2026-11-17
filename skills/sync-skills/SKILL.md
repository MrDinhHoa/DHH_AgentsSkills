---
name: sync-skills
description: Đồng bộ các skill dùng chung (bat-dau-phien, ket-thuc-phien, ...) từ repo agent-skills vào máy cho cả Claude Code và Antigravity. Dùng khi người dùng gõ /sync-skills hoặc nói "đồng bộ skill", "cập nhật skill".
---

<!-- Nguồn: repo agent-skills. Không sửa bản đã cài - sửa trong repo rồi chạy `sync-skills`. -->

# Đồng bộ skill dùng chung

1. Chạy lệnh terminal:
   ```
   sync-skills
   ```
   Lệnh này: `git pull` repo agent-skills (nếu có remote và không có thay đổi chưa commit) → copy `skills/*` vào `~/.claude/skills/` (Claude Code) và `~/.gemini/config/skills/` (Antigravity) → gỡ skill đã bị xóa khỏi repo.
   - Muốn bỏ qua `git pull`: `sync-skills -NoPull`.
2. Nếu báo không tìm thấy lệnh `sync-skills`: máy chưa cài → hướng dẫn người dùng clone repo agent-skills rồi chạy `install.bat` trong repo đó.
3. Báo lại kết quả (skill nào được cập nhật / gỡ). Nhắc: skill mới hoặc vừa thay đổi có thể cần **mở phiên mới** của Claude Code / Antigravity mới được nhận.

Sửa nội dung skill: sửa file trong repo agent-skills (`skills/<tên>/SKILL.md`), chạy `sync-skills -NoPull` để thử trên máy này, rồi commit + push để máy khác nhận được.
