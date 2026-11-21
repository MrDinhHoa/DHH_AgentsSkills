@echo off
rem Lenh `codex` dung file codex.exe kem trong extension Codex (openai.chatgpt) cua Antigravity / VS Code.
rem Tu chon ban extension moi nhat nen khong hong khi extension cap nhat.
rem Cai: copy file nay vao mot thu muc co trong PATH (vd. %USERPROFILE%\.local\bin).
setlocal
set "CODEX_EXE="
for %%R in ("%USERPROFILE%\.antigravity-ide\extensions" "%USERPROFILE%\.antigravity\extensions" "%USERPROFILE%\.vscode\extensions") do (
  if not defined CODEX_EXE if exist "%%~R" (
    for /f "delims=" %%D in ('dir /b /ad /o-d "%%~R\openai.chatgpt-*" 2^>nul') do (
      if not defined CODEX_EXE if exist "%%~R\%%D\bin\windows-x86_64\codex.exe" set "CODEX_EXE=%%~R\%%D\bin\windows-x86_64\codex.exe"
    )
  )
)
if not defined CODEX_EXE (
  echo [codex] Khong tim thay codex.exe trong extension Codex ^(openai.chatgpt^) cua Antigravity / VS Code. 1>&2
  exit /b 1
)
"%CODEX_EXE%" %*
exit /b %ERRORLEVEL%
