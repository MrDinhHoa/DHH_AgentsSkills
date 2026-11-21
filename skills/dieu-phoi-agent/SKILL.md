---
name: dieu-phoi-agent
description: Điều phối Codex CLI (OpenAI) và Gemini CLI (Google) làm agent phụ chạy headless - giao việc, chạy song song trong worktree riêng, review chéo, nghiệm thu và gộp kết quả. Dùng khi người dùng gõ /dieu-phoi-agent, hoặc nhờ "giao cho Codex", "nhờ Gemini", "cho Codex/Gemini review", "chạy song song nhiều agent", "lấy ý kiến thứ hai".
---

# Điều phối Codex & Gemini

Bạn (agent chính) là **người điều phối**: chia việc, viết đề bài, gọi agent phụ qua dòng lệnh, rồi **tự kiểm tra** kết quả trước khi báo người dùng. Agent phụ không thấy hội thoại hiện tại - đề bài phải tự đủ ngữ cảnh.

## 0. Kiểm tra công cụ (đầu mỗi phiên dùng skill)

```powershell
codex --version; codex login status
gemini --version
```

- **`codex` không có trong PATH** nhưng đã cài extension Codex (`openai.chatgpt`) trong Antigravity / VS Code: copy `scripts\codex.cmd` của skill này vào một thư mục có trong PATH (vd. `~\.local\bin`). Script tự tìm `codex.exe` kèm extension, bản mới nhất. Đăng nhập dùng chung với extension (`~\.codex\auth.json`).
- **Chưa có gì cả**: Codex → cài extension Codex, hoặc `npm i -g @openai/codex`; Gemini → `npm i -g @google/gemini-cli` (cần Node.js). Cả hai cài được **không cần quyền admin** (npm global mặc định nằm trong `%APPDATA%\npm`; Node có bản zip portable). Lần đầu chạy `codex login` / `gemini` ở chế độ tương tác để đăng nhập - việc này người dùng tự làm.
- Antigravity IDE **không** điều khiển được từ dòng lệnh (lệnh `antigravity-ide chat` đã thử, không mở được agent). Muốn phối hợp với agent trong IDE thì qua file (task/handoff), người dùng tự mở.

## 1. Khi nào giao, giao cho ai

| Tình huống | Làm gì |
|---|---|
| Việc nhỏ, sửa vài dòng | Tự làm - giao đi tốn thời gian hơn |
| Nhiều phần việc **độc lập** (khác file / khác module) | Chia cho Codex và Gemini chạy song song, mỗi agent một worktree |
| Cần ý kiến thứ hai: review diff, kiểm tra thiết kế, tìm bug | Chạy chế độ **chỉ đọc**, đưa cùng câu hỏi cho 1-2 agent, so sánh |
| Đọc / tóm tắt codebase lớn | Gemini (ngữ cảnh dài) chế độ chỉ đọc |

Trước khi giao việc có sửa code: nói ngắn gọn với người dùng sẽ giao gì cho ai. Việc tốn quota của tài khoản người dùng - không giao vô tội vạ.

## 2. Lệnh chuẩn

Đề bài dài → ghi vào file rồi đưa qua stdin, tránh lỗi quote trong shell.

**Tiếng Việt trên Windows PowerShell 5.1**: output của agent là UTF-8 → trước khi gọi, đặt `[Console]::OutputEncoding = [Text.Encoding]::UTF8`; đọc file kết quả bằng `Get-Content <file> -Encoding UTF8`. Không làm vậy sẽ bị lỗi font (mojibake).

### Codex (`codex exec`)

```powershell
# Chỉ đọc (review, phân tích)
codex exec -s read-only -C <thư mục> -o <kết quả.md> "<đề bài>"

# Được sửa file trong thư mục làm việc (dùng worktree riêng)
codex exec -s workspace-write -C <worktree> -o <kết quả.md> "<đề bài>"

# Đề bài từ file
Get-Content <task.md> -Raw | codex exec -s workspace-write -C <worktree> -o <kết quả.md> -
```

- `-o` ghi câu trả lời cuối ra file - đọc file này thay vì lọc log.
- Thư mục không phải git repo → thêm `--skip-git-repo-check`.
- `-m <model>` để chọn model; mặc định theo `~\.codex\config.toml`.
- **Không** dùng `-s danger-full-access` hay `--dangerously-bypass-approvals-and-sandbox`.

### Gemini (`gemini -p`)

Chạy với thư mục hiện tại là thư mục làm việc (đổi bằng `Set-Location` / `-C` của shell, hoặc `--include-directories`).

```powershell
# Chỉ đọc
gemini --skip-trust --approval-mode plan -p "<đề bài>"

# Được sửa file (chỉ trong worktree riêng)
gemini --skip-trust --approval-mode yolo -p "<đề bài>"

# Đề bài từ file (-p được nối sau nội dung stdin)
Get-Content <task.md> -Raw | gemini --skip-trust --approval-mode yolo -p "Thực hiện yêu cầu ở trên."
```

- `--skip-trust` là bắt buộc khi chạy headless trong thư mục chưa được trust.
- Chế độ headless không có ai bấm duyệt: `default` / `auto_edit` sẽ bị kẹt hoặc bị từ chối khi agent cần chạy lệnh → dùng `plan` (chỉ đọc) hoặc `yolo` (trong worktree cách ly).
- `-o json` nếu cần lấy kết quả có cấu trúc.

### Thời gian chạy

Agent phụ thường mất vài phút. Chạy nền (background) với giới hạn thời gian rộng (≥ 10 phút), nhiều agent thì chạy song song; trong lúc chờ có thể làm phần việc khác.

## 3. Cách ly khi cho sửa code

Không bao giờ để hai agent (kể cả bạn) sửa cùng một thư mục cùng lúc.

```powershell
git -C <repo> worktree add ..\<repo>-codex -b agent/codex-<việc>
git -C <repo> worktree add ..\<repo>-gemini -b agent/gemini-<việc>
```

Repo chưa dùng git → copy thư mục ra chỗ khác, hoặc chỉ giao việc chỉ đọc.

## 4. Mẫu đề bài

```
Bối cảnh: <dự án gì, công nghệ, file/thư mục liên quan>
Việc cần làm: <cụ thể, một mục tiêu>
Phạm vi: chỉ sửa <file/thư mục>. Không đụng <...>.
Xong khi: <build pass / test X pass / hành vi Y>
Quy tắc: không commit, không cài package mới, không sửa cấu hình ngoài phạm vi.
Báo cáo cuối: danh sách file đã sửa, tóm tắt thay đổi, lệnh đã chạy để kiểm tra và kết quả, điểm chưa chắc chắn.
```

Đề bài review: đưa diff (`git diff` ghi ra file) + yêu cầu "chỉ liệt kê lỗi thật kèm file:dòng và kịch bản gây lỗi, không sửa".

## 5. Nghiệm thu & gộp

1. Đọc file kết quả (`-o`) và **đọc diff thật**: `git -C <worktree> diff` - không tin báo cáo suông.
2. Tự build / chạy test trong worktree.
3. Kết quả review từ agent phụ: tự kiểm chứng từng điểm, loại báo động giả rồi mới báo người dùng.
4. Báo người dùng: ai làm gì, đã kiểm tra gì, còn gì chưa ổn. Gộp vào nhánh chính (merge / cherry-pick) **chỉ khi người dùng đồng ý**; commit / push theo quy tắc chung.
5. Dọn: `git worktree remove <worktree>` và xóa nhánh `agent/*` không dùng.

## 6. An toàn

- Không đưa secret (token, mật khẩu, `.env`) vào đề bài.
- Code của công ty / khách hàng: hỏi người dùng đã được phép gửi cho dịch vụ AI bên ngoài chưa.
- Agent phụ báo lỗi đăng nhập / hết quota → dừng, báo người dùng, không thử lại liên tục.
