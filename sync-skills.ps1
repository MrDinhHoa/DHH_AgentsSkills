# ==============================================================
# sync-skills: dong bo skill dung chung cho Claude Code + Antigravity
#   1. git pull repo DHH_AgentsSkills (bo qua bang -NoPull)
#   2. Copy skills\* vao:
#        - $HOME\.claude\skills           (Claude Code)
#        - $HOME\.gemini\config\skills    (Antigravity)
#   3. Go cac skill da bi xoa khoi repo (chi skill do script nay cai)
# ==============================================================
param(
    [switch]$NoPull,
    [switch]$Force   # ghi de ca skill trung ten khong do script nay cai
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$repo = $PSScriptRoot
$srcRoot = Join-Path $repo 'skills'
$marker = '.agent-skills'   # file danh dau skill do script nay quan ly

$targets = [ordered]@{
    'Claude Code' = Join-Path $HOME '.claude\skills'
    'Antigravity' = Join-Path $HOME '.gemini\config\skills'
}

# ---------- 1. git pull ----------
if (-not $NoPull) {
    $hasRemote = (git -C $repo remote 2>$null)
    if (-not $hasRemote) {
        Write-Host "[--] Repo chua co remote, bo qua git pull." -ForegroundColor DarkGray
    } elseif (git -C $repo status --porcelain) {
        Write-Host "[!!] Repo co thay doi chua commit, bo qua git pull (commit/push truoc)." -ForegroundColor Yellow
    } else {
        Write-Host "[..] git pull ..." -ForegroundColor Cyan
        $selfHashBefore = (Get-FileHash $PSCommandPath).Hash
        $installHashBefore = (Get-FileHash (Join-Path $repo 'install.ps1')).Hash
        git -C $repo pull --ff-only
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[!!] git pull that bai, dung ban hien co tren may." -ForegroundColor Yellow
        } else {
            if ((Get-FileHash (Join-Path $repo 'install.ps1')).Hash -ne $installHashBefore) {
                Write-Host "[!!] install.ps1 vua thay doi -> nen chay lai install.bat de cap nhat lenh sync-skills." -ForegroundColor Yellow
            }
            # Chinh script nay vua duoc cap nhat -> chay lai bang ban moi (PowerShell dang chay ban cu da nap)
            if ((Get-FileHash $PSCommandPath).Hash -ne $selfHashBefore) {
                Write-Host "[..] sync-skills vua duoc cap nhat -> chay lai bang ban moi ..." -ForegroundColor Cyan
                $argsNew = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-NoPull')
                if ($Force) { $argsNew += '-Force' }
                & powershell.exe @argsNew
                exit $LASTEXITCODE
            }
        }
    }
}

# ---------- 2. Cai skill ----------
$skills = Get-ChildItem $srcRoot -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }
if (-not $skills) { Write-Host "[LOI] Khong co skill nao trong $srcRoot" -ForegroundColor Red; exit 1 }
$names = $skills.Name

foreach ($t in $targets.GetEnumerator()) {
    $dstRoot = $t.Value
    Write-Host "`n== $($t.Key): $dstRoot" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $dstRoot | Out-Null

    foreach ($s in $skills) {
        $dst = Join-Path $dstRoot $s.Name
        if ((Test-Path $dst) -and -not (Test-Path (Join-Path $dst $marker)) -and -not $Force) {
            Write-Host "  [!!] $($s.Name): da co skill trung ten khong do sync-skills cai -> bo qua (dung -Force de ghi de)" -ForegroundColor Yellow
            continue
        }
        if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
        Copy-Item $s.FullName $dst -Recurse -Force
        Set-Content -Path (Join-Path $dst $marker) -Value "Cai boi sync-skills tu: $repo" -Encoding ASCII
        Write-Host "  [OK] $($s.Name)" -ForegroundColor Green
    }

    # ---------- 3. Go skill da xoa khoi repo ----------
    Get-ChildItem $dstRoot -Directory | Where-Object {
        (Test-Path (Join-Path $_.FullName $marker)) -and ($names -notcontains $_.Name)
    } | ForEach-Object {
        Remove-Item $_.FullName -Recurse -Force
        Write-Host "  [--] Da go: $($_.Name) (khong con trong repo)" -ForegroundColor DarkYellow
    }
}

# ---------- 4. Chen quy tac chung vao file huong dan toan cuc ----------
#   Chi thay phan giua 2 dong danh dau; noi dung khac trong file duoc giu nguyen.
$rulesFile = Join-Path $repo 'rules\agent-skills-rules.md'
$ruleTargets = [ordered]@{
    'Claude Code' = Join-Path $HOME '.claude\CLAUDE.md'
    'Antigravity' = Join-Path $HOME '.gemini\config\AGENTS.md'
}
if (Test-Path $rulesFile) {
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    $begin = '<!-- BEGIN agent-skills (tu dong boi sync-skills - khong sua tay) -->'
    $end = '<!-- END agent-skills -->'
    $rules = [IO.File]::ReadAllText($rulesFile, $utf8).Trim().Replace('{{AGENT_SKILLS_DIR}}', $repo)
    $block = "$begin`r`n$rules`r`n$end"
    $pattern = '(?s)<!-- BEGIN agent-skills.*?<!-- END agent-skills -->'

    Write-Host "`n== Quy tac chung" -ForegroundColor Cyan
    foreach ($t in $ruleTargets.GetEnumerator()) {
        $file = $t.Value
        New-Item -ItemType Directory -Force -Path (Split-Path $file -Parent) | Out-Null
        if (Test-Path $file) {
            $text = [IO.File]::ReadAllText($file, $utf8)
            if ([regex]::IsMatch($text, $pattern)) {
                $evaluator = [System.Text.RegularExpressions.MatchEvaluator] { param($m) $block }
                $new = [regex]::Replace($text, $pattern, $evaluator)
            } else {
                $new = $text.TrimEnd() + "`r`n`r`n" + $block + "`r`n"
            }
        } else {
            $new = $block + "`r`n"
        }
        [IO.File]::WriteAllText($file, $new, $utf8)
        Write-Host "  [OK] $($t.Key): $file" -ForegroundColor Green
    }
}

Write-Host "`nXong. Mo phien moi cua Claude Code / Antigravity de nhan skill moi." -ForegroundColor Green
