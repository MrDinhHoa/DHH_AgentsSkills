# Cai cong cu agent (Node.js portable, Gemini CLI, ripgrep, lenh codex) - KHONG can quyen admin.
# Chay lai nhieu lan duoc: thu nao co roi thi bo qua.
# Sau khi chay: mo terminal MOI, chay `gemini` 1 lan de dang nhap.
param(
  [string]$NodeDir = "$env:LOCALAPPDATA\Programs\nodejs",
  [switch]$ForceNode,      # cai Node du da co (dung de thu)
  [switch]$NoPathChange    # khong sua PATH nguoi dung (dung de thu)
)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'
$repo = $PSScriptRoot

function Show-Head($m) { Write-Host "`n===== $m =====" -ForegroundColor Cyan }
function Show-Ok($m)   { Write-Host "[OK]   $m" -ForegroundColor Green }
function Show-Skip($m) { Write-Host "[BO QUA] $m" -ForegroundColor DarkGray }
function Show-Err($m)  { Write-Host "[LOI]  $m" -ForegroundColor Red }
function Update-SessionPath { $env:Path = [Environment]::GetEnvironmentVariable('Path','User') + ';' + [Environment]::GetEnvironmentVariable('Path','Machine') }
function Add-UserPath($dir) {
  if ($NoPathChange) { $env:Path = "$dir;$env:Path"; return }
  $cur = [Environment]::GetEnvironmentVariable('Path','User')
  $parts = @($cur -split ';' | Where-Object { $_ })
  if (-not ($parts | Where-Object { $_.TrimEnd('\') -ieq $dir.TrimEnd('\') })) {
    [Environment]::SetEnvironmentVariable('Path', (($parts + $dir) -join ';'), 'User')
    Show-Ok "Them vao PATH nguoi dung: $dir"
  }
  Update-SessionPath
}
Update-SessionPath
$failed = @()

# 1. Node.js portable
Show-Head "1. Node.js"
try {
  if ((Get-Command node -ErrorAction SilentlyContinue) -and -not $ForceNode) {
    Show-Skip "Da co node $(node --version)"
  } else {
    $index = Invoke-RestMethod 'https://nodejs.org/dist/index.json'   # gan bien truoc: PS 5.1 khong tach mang JSON trong pipeline
    $lts = ($index | Where-Object { $_.lts } | Select-Object -First 1).version
    if (-not $lts) { throw "Khong tim thay ban Node LTS" }
    $name = "node-$lts-win-x64"
    $tmp = Join-Path $env:TEMP "agent-tools-node"
    if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
    New-Item -ItemType Directory $tmp | Out-Null
    Write-Host "Tai $name.zip ..."
    Invoke-WebRequest "https://nodejs.org/dist/$lts/$name.zip" -OutFile "$tmp\node.zip" -UseBasicParsing
    Expand-Archive "$tmp\node.zip" $tmp -Force
    if (Test-Path $NodeDir) { Remove-Item $NodeDir -Recurse -Force }
    New-Item -ItemType Directory -Force (Split-Path $NodeDir) | Out-Null
    Move-Item "$tmp\$name" $NodeDir
    Remove-Item $tmp -Recurse -Force
    Add-UserPath $NodeDir
    Show-Ok "Node $lts -> $NodeDir"
  }
} catch { Show-Err "Node: $($_.Exception.Message)"; $failed += 'node' }

# 2. Thu muc npm global (khong can admin)
Show-Head "2. npm global"
try {
  $npmDir = Join-Path $env:APPDATA 'npm'
  New-Item -ItemType Directory -Force $npmDir | Out-Null
  $npm = (Get-Command npm.cmd -ErrorAction Stop).Source
  if (-not $NoPathChange) { & $npm config set prefix $npmDir --location=user | Out-Null }
  Add-UserPath $npmDir
  Show-Ok "npm global: $npmDir"
} catch { Show-Err "npm: $($_.Exception.Message)"; $failed += 'npm' }

# 3. Gemini CLI
Show-Head "3. Gemini CLI"
try {
  if (Get-Command gemini -ErrorAction SilentlyContinue) { Show-Skip "Da co gemini" }
  else {
    & (Get-Command npm.cmd -ErrorAction Stop).Source i -g '@google/gemini-cli'
    if ($LASTEXITCODE -ne 0) { throw "npm i -g @google/gemini-cli exit $LASTEXITCODE" }
    Update-SessionPath
    Show-Ok "Gemini CLI da cai"
  }
} catch { Show-Err "Gemini: $($_.Exception.Message)"; $failed += 'gemini' }

# 4. ripgrep
Show-Head "4. ripgrep"
try {
  if (Get-Command rg -ErrorAction SilentlyContinue) { Show-Skip "Da co rg" }
  elseif (Get-Command winget -ErrorAction SilentlyContinue) {
    winget install --id BurntSushi.ripgrep.MSVC -e --scope user --accept-source-agreements --accept-package-agreements --disable-interactivity
    if ($LASTEXITCODE -ne 0) { throw "winget exit $LASTEXITCODE" }
    Show-Ok "ripgrep da cai"
  } else { throw "khong co winget" }
} catch { Show-Err "ripgrep: $($_.Exception.Message)"; $failed += 'ripgrep' }

# 5. Lenh codex (tu extension Codex trong Antigravity / VS Code)
Show-Head "5. Lenh codex"
try {
  $bin = Join-Path $env:USERPROFILE '.local\bin'
  New-Item -ItemType Directory -Force $bin | Out-Null
  Copy-Item (Join-Path $repo 'skills\dieu-phoi-agent\scripts\codex.cmd') (Join-Path $bin 'codex.cmd') -Force
  Add-UserPath $bin
  $v = & (Join-Path $bin 'codex.cmd') --version 2>&1
  if ($LASTEXITCODE -ne 0) { throw "$v" }
  Show-Ok "codex -> $v"
} catch { Show-Err "codex: $($_.Exception.Message)"; $failed += 'codex' }

Show-Head "KET QUA"
if ($failed) { Show-Err "Loi o: $($failed -join ', ') - xem thong bao phia tren." } else { Show-Ok "Xong tat ca." }
Write-Host @"

Tiep theo:
  1. Dong terminal nay, mo terminal MOI (de nhan PATH moi).
  2. Chay:  gemini           -> dang nhap Google lan dau (chon 'Login with Google'), xong go /quit
  3. Kiem tra: codex login status
"@ -ForegroundColor Cyan
