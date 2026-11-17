# ==============================================================
# Cai dat lenh `sync-skills` toan cuc + dong bo skill lan dau
# Chay 1 lan tren moi may (sau khi clone repo DHH_AgentsSkills).
# ==============================================================

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
Write-Host "Cai dat sync-skills (repo: $repo)" -ForegroundColor Cyan

# 1. Thu muc lenh: ~/.local/bin (dung chung voi csbuild)
$binDir = Join-Path $HOME '.local\bin'
New-Item -ItemType Directory -Force -Path $binDir | Out-Null

# 2. Tao sync-skills.cmd tro toi script trong repo (chay duoc trong CMD, PowerShell, Git Bash)
$cmd = "@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -File ""$repo\sync-skills.ps1"" %*"
Set-Content -Path (Join-Path $binDir 'sync-skills.cmd') -Value $cmd -Encoding ASCII
Write-Host "[OK] Da tao $binDir\sync-skills.cmd" -ForegroundColor Green

# 3. Them ~/.local/bin vao User PATH neu chua co
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $binDir) {
    [Environment]::SetEnvironmentVariable('Path', "$binDir;$userPath", 'User')
    $env:Path = "$binDir;$env:Path"
    Write-Host "[OK] Da them $binDir vao PATH cua User (mo Terminal moi de co hieu luc)" -ForegroundColor Green
} else {
    Write-Host "[OK] $binDir da co trong PATH" -ForegroundColor Green
}

# 4. Dong bo lan dau
& (Join-Path $repo 'sync-skills.ps1') -NoPull

Write-Host "`n>>> CAI DAT THANH CONG <<<" -ForegroundColor Green
Write-Host "Tu nay go 'sync-skills' o bat ky dau de cap nhat skill." -ForegroundColor Yellow
