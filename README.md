# DHH_AgentsSkills

Skill và quy tắc dùng chung cho **Claude Code** và **Antigravity**, đồng bộ giữa các máy qua git.

```
skills\<tên>\SKILL.md          ← các skill
rules\agent-skills-rules.md    ← quy tắc chung (cách quản lý skill), chèn vào file hướng dẫn toàn cục
sync-skills.ps1                ← git pull + cài skill + chèn quy tắc
install.bat / install.ps1      ← cài lệnh `sync-skills` (1 lần mỗi máy)
kiem-tra-may.bat / .ps1        ← kiểm tra máy trước khi cài công cụ agent (chỉ đọc)
```

### 1. Quy trình làm việc & Quản lý phiên
| Skill | Lệnh | Việc làm |
|---|---|---|
| `bat-dau-phien` | `/bat-dau-phien [solution\|project\|số]` | Đầu phiên: đọc tài liệu (`AGENTS.md`, `PROJECT_HANDOFF.md`, các `CLAUDE.md`), kiểm tra git, báo cáo trạng thái + việc tiếp theo. Hỗ trợ chọn phạm vi theo Solution (.sln/.slnx), từng Project hoặc số thứ tự (tương tự csbuild). Chỉ đọc. |
| `ket-thuc-phien` | `/ket-thuc-phien [số\|project] [ghi chú]` | Cuối phiên: cập nhật `CLAUDE.md` của project đã sửa, `PROJECT_HANDOFF.md`, `AGENTS.md`. Hỗ trợ chọn project theo số thứ tự hoặc tên trước khi cập nhật. Không commit. |
| `sync-skills` | `/sync-skills` | Chạy lệnh `sync-skills` để cập nhật skill trên máy. |
| `dieu-phoi-agent` | `/dieu-phoi-agent` | Điều phối Codex CLI và Gemini CLI làm agent phụ chạy headless: giao việc, chạy song song trong worktree riêng, review chéo, nghiệm thu và gộp kết quả. Kèm `scripts\codex.cmd` tạo lệnh `codex` từ `codex.exe` trong extension Codex của Antigravity / VS Code. |
| `find-skills` | `/find-skills` | Hỗ trợ tìm kiếm, tra cứu và đề xuất kỹ năng từ hệ sinh thái mở skills.sh và GitHub. Nguồn: `vercel-labs/skills`. |

### 2. Thiết kế UI/UX & Frontend
| Skill | Lệnh | Việc làm |
|---|---|---|
| `design-taste-frontend` | `/design-taste-frontend` | Xây dựng giao diện web/landing page chuyên nghiệp (chuẩn figma.com, x.ai), chống phong cách AI rập khuôn (anti-slop). Hệ thống layout, typography, micro-interactions, phối màu. Nguồn: `Leonxlnx/taste-skill`. |
| `ui-ux-pro-max` | `/ui-ux-pro-max` | Trí tuệ thiết kế UI/UX đa nền tảng (web, mobile, desktop): tra cứu 80 phong cách UI, 192 bảng màu theo sản phẩm, 74 cặp font chữ, 120 nguyên tắc UX, biểu đồ và 22 tech stack bằng công cụ tìm kiếm BM25 cục bộ. Nguồn: `nextlevelbuilder/ui-ux-pro-max-skill`. |

### 3. Nền tảng .NET Hiện Đại (từ `managedcode/dotnet-skills`)
| Skill | Lệnh | Việc làm |
|---|---|---|
| `modern-csharp` | `/modern-csharp` | Viết C# hiện đại, tối ưu (C# 12/13), tương thích target framework, áp dụng các tính năng ngôn ngữ mới nhất. |
| `wpf` | `/wpf` | Xây dựng và hiện đại hóa ứng dụng WPF (.NET & .NET Framework): XAML, Data Binding, Commands, ControlTemplates, ResourceDictionary, Dispatcher threading. |
| `aspnet-core` | `/aspnet-core` | Kiến trúc ứng dụng ASP.NET Core: hosting, middleware, bảo mật, cấu hình, logging, DI theo chuẩn .NET mới nhất. |
| `minimal-apis` | `/minimal-apis` | Thiết kế và hiện thực Minimal APIs: route groups, filters, handler endpoints gọn nhẹ cho microservice. |
| `entity-framework-core` | `/entity-framework-core` | Thiết kế dữ liệu EF Core: modeling, migrations, tối ưu truy vấn LINQ, tracking, quan hệ dữ liệu hiệu năng cao. |
| `xunit` | `/xunit` | Viết, chạy và sửa lỗi unit test với xUnit (v2/v3), Microsoft.Testing.Platform, mock và assertion chuẩn. |

### 4. .NET Clean Architecture, CQRS & DDD (Bộ 29 skills từ `ronnythedev/dotnet-clean-architecture-skills`)
| Skill | Lệnh | Việc làm |
|---|---|---|
| `dotnet-clean-architecture` | `/dotnet-clean-architecture` | Scaffolding giải pháp .NET Clean Architecture phân tầng chuẩn (API, Application, Domain, Infrastructure). |
| `dotnet-cqrs-command-generator` | `/dotnet-cqrs-command-generator` | Tạo Command, Handler, Validator, Request DTO theo mô hình CQRS + MediatR + Result pattern. |
| `dotnet-cqrs-query-generator` | `/dotnet-cqrs-query-generator` | Tạo Query, Handler, Response DTO cho tác vụ đọc dữ liệu (tối ưu với Dapper). |
| `dotnet-domain-entity-generator` | `/dotnet-domain-entity-generator` | Tạo DDD Domain Entity, Aggregate Root, Value Object, Factory method `Create()` và private setters. |
| `dotnet-domain-events-generator` | `/dotnet-domain-events-generator` | Tạo Domain Events, MediatR notification handlers, tích hợp Outbox pattern. |
| `dotnet-repository-pattern` | `/dotnet-repository-pattern` | Thiết kế Repository interfaces và EF Core implementations trừu tượng hóa truy cập dữ liệu. |
| `dotnet-ef-core-configuration` | `/dotnet-ef-core-configuration` | Cấu hình EF Core Fluent API, quan hệ bảng, indexes, constraints. |
| `dotnet-minimal-api-endpoints` | `/dotnet-minimal-api-endpoints` | Xây dựng Minimal API endpoints (MapGet/MapPost) tích hợp MediatR, validation, filters. |
| `dotnet-legacy-api-controllers` | `/dotnet-legacy-api-controllers` | Xây dựng RESTful API Controllers truyền thống với routing, versioning, authorization. |
| `dotnet-result-pattern` | `/dotnet-result-pattern` | Xử lý lỗi tường minh không dùng exception qua Result, Result<T>, Error types. |
| `dotnet-pipeline-behaviors` | `/dotnet-pipeline-behaviors` | Tạo MediatR Pipeline Behaviors: Logging, Validation, Transaction, Performance, Caching. |
| `dotnet-fluent-validation` | `/dotnet-fluent-validation` | Tạo bộ validate FluentValidation cho Command/Query, async validation. |
| `dotnet-jwt-authentication` | `/dotnet-jwt-authentication` | Cấu hình JWT Bearer auth, token generation, refresh tokens, claims principal. |
| `dotnet-permission-authorization` | `/dotnet-permission-authorization` | Phân quyền chi tiết dựa trên permission (Permission-based auth) với policy providers. |
| `dotnet-outbox-pattern` | `/dotnet-outbox-pattern` | Triển khai Outbox pattern để lưu và gửi Domain Events an toàn cùng transaction. |
| `dotnet-quartz-background-jobs` | `/dotnet-quartz-background-jobs` | Cấu hình scheduled background jobs với Quartz.NET, cron schedule, clustering. |
| `dotnet-dapper-query-builder` | `/dotnet-dapper-query-builder` | Truy vấn đọc dữ liệu hiệu năng cao với Dapper, multi-mapping, CTEs, dynamic filters. |
| `dotnet-specification-pattern` | `/dotnet-specification-pattern` | Đóng gói logic truy vấn tái sử dụng qua Specification pattern (include, sorting, paging). |
| `dotnet-unit-testing` | `/dotnet-unit-testing` | Viết unit test cho Command/Query handlers dùng xUnit và NSubstitute/Moq. |
| `dotnet-integration-testing` | `/dotnet-integration-testing` | Viết integration test với WebApplicationFactory và Testcontainers. |
| `dotnet-logging-configuration` | `/dotnet-logging-configuration` | Cấu hình Serilog structured logging, log enrichment, source generators. |
| `dotnet-rate-limiting` | `/dotnet-rate-limiting` | Cấu hình Rate Limiting middleware bảo vệ API (fixed/sliding window, token bucket). |
| `dotnet-options-pattern` | `/dotnet-options-pattern` | Strongly-typed configuration với IOptions<T>, IOptionsSnapshot<T>, IOptionsMonitor<T>. |
| `dotnet-health-checks` | `/dotnet-health-checks` | Cấu hình Health Checks cho database, microservices, liveness/readiness probes. |
| `dotnet-audit-trail` | `/dotnet-audit-trail` | Tự động ghi vết kiểm toán (IAuditable, CreatedBy, UpdatedBy) qua EF Core Interceptor. |
| `dotnet-postgresql-best-practices` | `/dotnet-postgresql-best-practices` | Thực hành tối ưu PostgreSQL, Npgsql, EF Core (jsonb, indexing, naming convention). |
| `dotnet-sqlserver-best-practices` | `/dotnet-sqlserver-best-practices` | Thực hành tối ưu SQL Server, Microsoft.Data.SqlClient, EF Core (indexes, performance). |
| `dotnet-email-service-sendgrid` | `/dotnet-email-service-sendgrid` | Dịch vụ gửi email qua SendGrid với template, localization, async. |
| `dotnet-email-service-aws-ses` | `/dotnet-email-service-aws-ses` | Dịch vụ gửi email qua AWS SES với HTML template và Result pattern. |

### 5. Review Code, Tài Liệu & Lập Kế Hoạch (từ `github/awesome-copilot`)
| Skill | Lệnh | Việc làm |
|---|---|---|
| `review-and-refactor` | `/review-and-refactor` | Review chất lượng mã nguồn chuyên sâu, phát hiện code smell, tối ưu hóa và refactor clean code an toàn. |
| `dotnet-design-pattern-review` | `/dotnet-design-pattern-review` | Review việc áp dụng Design Patterns chuyên sâu cho dự án C#/.NET (Command, Factory, DI, Repository, Provider...). |
| `documentation-writer` | `/documentation-writer` | Soạn thảo tài liệu phần mềm chuyên nghiệp theo khung Diátaxis chuẩn quốc tế (Tutorials, How-to, Reference, Explanation). |
| `create-implementation-plan` | `/create-implementation-plan` | Lập kế hoạch triển khai tính năng / nâng cấp / refactor chi tiết từng bước, máy đọc được, phân rã công việc rõ ràng. |
| `architecture-blueprint-generator` | `/architecture-blueprint-generator` | Phân tích codebase và sinh bản vẽ kiến trúc hệ thống toàn diện (`Project_Architecture_Blueprint.md`) kèm sơ đồ Mermaid. |

## Cài trên máy mới (1 lần)

```powershell
git clone https://github.com/MrDinhHoa/DHH_AgentsSkills.git "D:\01_WORKING\00_Agent Skills"
& "D:\01_WORKING\00_Agent Skills\install.bat"
```
Có thể clone vào thư mục bất kỳ; nếu sau này **di chuyển thư mục repo**, chạy lại `install.bat` ở vị trí mới để lệnh `sync-skills` trỏ đúng chỗ.
`install` tạo lệnh `sync-skills` trong `~\.local\bin` (thêm vào PATH nếu chưa có), cài skill và chèn quy tắc chung lần đầu.

### Kiểm tra máy (máy công ty / không có quyền admin)

Nhấp đúp `kiem-tra-may.bat` (không cần admin). Script **chỉ đọc**, kiểm tra:

| Mục | Nội dung |
|---|---|
| Phần mềm | `node`, `npm`, `git`, `winget`, `gemini`, `codex`, `claude`, `rg`; VS Code / Antigravity; `codex.exe` trong extension Codex; Codex đã đăng nhập chưa |
| PATH | `~\.local\bin`, `%APPDATA%\npm` có trong PATH người dùng; ghi được vào `%APPDATA%\npm` không (để `npm i -g` không cần admin) |
| Chính sách | Execution policy; có bị chặn chạy `.exe` trong thư mục người dùng không (AppLocker...) |
| Mạng | Proxy (IE / WinHTTP / `HTTPS_PROXY`); kết nối tới OpenAI, Google, Anthropic, npm, GitHub, nodejs.org |

Kết quả lưu vào `kiem-tra-may.txt` trên Desktop. Chưa có repo trên máy đó: mở file `kiem-tra-may.ps1`, copy toàn bộ nội dung dán vào cửa sổ PowerShell.

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
