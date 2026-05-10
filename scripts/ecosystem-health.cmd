@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

rem Prefer PowerShell Core if available
set "PS=powershell.exe"
where pwsh >nul 2>nul && set "PS=pwsh"

%PS% -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\ecosystem-health.ps1" %*

set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
