# Cai cong cu agent (Node.js portable, Gemini CLI, ripgrep, lenh codex) - KHONG can quyen admin.
# Chay lai nhieu lan duoc: thu nao co roi thi bo qua.
# Sau khi chay: mo terminal MOI, chay `gemini` 1 lan va nhap Gemini API key.
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
  # Doc/ghi thang registry: giu nguyen cac muc %VAR% va kieu REG_EXPAND_SZ
  # ([Environment]::SetEnvironmentVariable se ghi lai PATH da giai no, mat %VAR%).
  $key = Get-Item 'HKCU:\Environment'
  $raw = $key.GetValue('Path', '', 'DoNotExpandEnvironmentNames')
  $parts = @($raw -split ';' | Where-Object { $_ })
  $exists = $parts | Where-Object { [Environment]::ExpandEnvironmentVariables($_).TrimEnd('\') -ieq $dir.TrimEnd('\') }
  if (-not $exists) {
    Set-ItemProperty 'HKCU:\Environment' -Name Path -Value (($parts + $dir) -join ';') -Type ExpandString
    # Bao cho Windows (Explorer, terminal moi) biet bien moi truong da doi
    [Environment]::SetEnvironmentVariable('AGENT_TOOLS_REFRESH', '1', 'User')
    [Environment]::SetEnvironmentVariable('AGENT_TOOLS_REFRESH', $null, 'User')
    Show-Ok "Them vao PATH nguoi dung: $dir"
  }
  Update-SessionPath
}
Update-SessionPath
$failed = @()

# 0. ExecutionPolicy cho user (npm.ps1, gemini.ps1 la script .ps1; mac dinh Restricted se bi chan)
Show-Head "0. ExecutionPolicy"
try {
  if ((Get-ExecutionPolicy -Scope CurrentUser) -in @('Undefined','Restricted')) {
    if (-not $NoPathChange) { Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force }
    Show-Ok "CurrentUser -> RemoteSigned"
  } else { Show-Skip "CurrentUser = $(Get-ExecutionPolicy -Scope CurrentUser)" }
} catch { Show-Err "ExecutionPolicy (co the bi GPO khoa): $($_.Exception.Message)"; $failed += 'executionpolicy' }

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
  # PS 5.1: EAP=Stop + 2>&1 bien moi dong stderr (vd. canh bao) thanh loi dung -> tam ha EAP
  $ErrorActionPreference = 'Continue'
  try { $v = & (Join-Path $bin 'codex.cmd') --version 2>&1 | ForEach-Object { "$_" } } finally { $ErrorActionPreference = 'Stop' }
  if ($LASTEXITCODE -ne 0) { throw "$v" }
  Show-Ok "codex -> $v"
} catch { Show-Err "codex: $($_.Exception.Message)"; $failed += 'codex' }

# 6. Antigravity CLI (agy) - dung goi Google AI Pro/Ultra (Gemini CLI khong con nhan tai khoan ca nhan)
Show-Head "6. Antigravity CLI (agy)"
try {
  $agyExe = Join-Path $env:LOCALAPPDATA 'agy\bin\agy.exe'
  if ((Get-Command agy -ErrorAction SilentlyContinue) -or (Test-Path $agyExe)) { Show-Skip "Da co agy" }
  else {
    $tmp = Join-Path $env:TEMP 'agent-tools-agy'
    New-Item -ItemType Directory -Force $tmp | Out-Null
    Invoke-WebRequest 'https://antigravity.google/cli/install.ps1' -OutFile "$tmp\install.ps1" -UseBasicParsing
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$tmp\install.ps1"
    Remove-Item $tmp -Recurse -Force
    if (-not (Test-Path $agyExe)) { throw "khong thay $agyExe sau khi cai" }
    Show-Ok "agy -> $agyExe"
  }
} catch { Show-Err "agy: $($_.Exception.Message)"; $failed += 'agy' }

Show-Head "KET QUA"
if ($failed) { Show-Err "Loi o: $($failed -join ', ') - xem thong bao phia tren." } else { Show-Ok "Xong tat ca." }
Write-Host @"

Tiep theo:
  1. Dong terminal nay, mo terminal MOI (de nhan PATH moi).
  2. Lay API key tai https://aistudio.google.com/apikey
     Chay:  gemini   -> chon 'Use Gemini API Key', dan key, xong go /quit
     (Dang nhap bang tai khoan Google khong con ho tro cho Gemini CLI ca nhan.)
  3. Kiem tra: codex login status
  4. Chay:  agy   -> dang nhap Google (tai khoan co goi AI Pro/Ultra), xong thoat.
     (Neu da dang nhap Antigravity IDE thi co the agy da dung chung, khong can.)
"@ -ForegroundColor Cyan
