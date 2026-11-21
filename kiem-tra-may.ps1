# Kiem tra may truoc khi cai cong cu agent (Claude Code, Codex, Gemini CLI).
# CHI DOC - khong cai, khong sua gi. Chay duoc khong can quyen admin.
# Ket qua duoc luu them vao file kiem-tra-may.txt tren Desktop.

$outFile = Join-Path ([Environment]::GetFolderPath('Desktop')) 'kiem-tra-may.txt'
try { Start-Transcript -Path $outFile -Force | Out-Null } catch { $outFile = $null }

function Show-Ok($m)   { Write-Host "[OK]      $m" -ForegroundColor Green }
function Show-No($m)   { Write-Host "[KHONG]   $m" -ForegroundColor Yellow }
function Show-Bad($m)  { Write-Host "[BI CHAN] $m" -ForegroundColor Red }
function Show-Head($m) { Write-Host "`n===== $m =====" -ForegroundColor Cyan }

Show-Head "0. MAY"
Write-Host "Windows   : $([Environment]::OSVersion.VersionString)"
Write-Host "Kien truc : $env:PROCESSOR_ARCHITECTURE"
Write-Host "PowerShell: $($PSVersionTable.PSVersion)"
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Host "Dang chay quyen admin: $isAdmin"

Show-Head "1. PHAN MEM"
foreach ($c in 'node','npm','git','winget','gemini','codex','agy','claude','rg') {
  $x = Get-Command $c -ErrorAction SilentlyContinue
  if ($x) {
    $v = try { & $c --version 2>$null | Select-Object -First 1 } catch { '?' }
    Show-Ok ("{0,-7} {1}  ({2})" -f $c, $v, $x.Source)
  } else { Show-No $c }
}
foreach ($p in "$env:LOCALAPPDATA\Programs\Microsoft VS Code","$env:ProgramFiles\Microsoft VS Code","$env:LOCALAPPDATA\Programs\Antigravity IDE","$env:LOCALAPPDATA\Programs\antigravity") {
  if (Test-Path $p) { Show-Ok "IDE: $p" }
}
$codexExt = foreach ($r in "$env:USERPROFILE\.antigravity-ide\extensions","$env:USERPROFILE\.antigravity\extensions","$env:USERPROFILE\.vscode\extensions") {
  if (Test-Path $r) { Get-ChildItem $r -Directory -Filter 'openai.chatgpt-*' -ErrorAction SilentlyContinue | ForEach-Object { Get-ChildItem $_.FullName -Recurse -Filter 'codex.exe' -ErrorAction SilentlyContinue } }
}
if ($codexExt) { $codexExt | ForEach-Object { Show-Ok "codex.exe trong extension: $($_.FullName)" } } else { Show-No "Extension Codex (openai.chatgpt) trong Antigravity / VS Code" }
if (Test-Path "$env:LOCALAPPDATA\agy\bin\agy.exe") { Show-Ok "agy.exe: $env:LOCALAPPDATA\agy\bin\agy.exe" } else { Show-No "Antigravity CLI (agy)" }
if (Test-Path "$env:USERPROFILE\.codex\auth.json") { Show-Ok "Codex da dang nhap (~\.codex\auth.json)" } else { Show-No "Codex chua dang nhap" }

Show-Head "2. PATH NGUOI DUNG"
$userPath = [Environment]::GetEnvironmentVariable('Path','User') -split ';' | Where-Object { $_ }
foreach ($want in "$env:USERPROFILE\.local\bin","$env:APPDATA\npm") {
  if ($userPath | Where-Object { $_.TrimEnd('\') -ieq $want }) { Show-Ok "Co trong PATH: $want" } else { Show-No "Chua co trong PATH: $want" }
}
$t = Join-Path $env:APPDATA 'npm\_kt_write_test.tmp'
try { New-Item -ItemType Directory -Force (Split-Path $t) | Out-Null; Set-Content $t 'x' -ErrorAction Stop; Remove-Item $t -Force; Show-Ok "Ghi duoc vao %APPDATA%\npm (npm i -g khong can admin)" }
catch { Show-Bad "Khong ghi duoc vao %APPDATA%\npm: $($_.Exception.Message)" }

Show-Head "3. CHINH SACH SCRIPT"
Get-ExecutionPolicy -List | Format-Table -AutoSize | Out-String | Write-Host

Show-Head "4. CHAY EXE TU THU MUC NGUOI DUNG"
$t = Join-Path $env:LOCALAPPDATA 'kt_exe_test.exe'
try { Copy-Item "$env:WINDIR\System32\whoami.exe" $t -Force; $null = & $t; Show-Ok "Chay duoc exe trong thu muc nguoi dung" }
catch { Show-Bad "Khong chay duoc exe trong thu muc nguoi dung: $($_.Exception.Message)" }
finally { Remove-Item $t -Force -ErrorAction SilentlyContinue }

Show-Head "5. PROXY"
$is = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -ErrorAction SilentlyContinue
Write-Host "ProxyEnable   : $($is.ProxyEnable)"
Write-Host "ProxyServer   : $($is.ProxyServer)"
Write-Host "AutoConfigURL : $($is.AutoConfigURL)"
Write-Host "HTTPS_PROXY   : $env:HTTPS_PROXY"
netsh winhttp show proxy | Write-Host

Show-Head "6. KET NOI MANG"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
foreach ($u in 'https://api.openai.com','https://chatgpt.com','https://auth.openai.com','https://generativelanguage.googleapis.com','https://accounts.google.com','https://api.anthropic.com','https://claude.ai','https://registry.npmjs.org','https://github.com','https://nodejs.org') {
  try { $null = Invoke-WebRequest $u -Method Head -UseBasicParsing -TimeoutSec 10; Show-Ok $u }
  catch {
    if ($_.Exception.Response) { Show-Ok "$u (HTTP $([int]$_.Exception.Response.StatusCode))" }
    else { Show-Bad "$u : $($_.Exception.Message)" }
  }
}

Write-Host "`nXONG." -ForegroundColor Cyan
if ($outFile) { try { Stop-Transcript | Out-Null } catch {}; Write-Host "Ket qua da luu: $outFile  -> gui file nay lai." -ForegroundColor Cyan }
