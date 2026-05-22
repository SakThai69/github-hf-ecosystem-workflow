@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

set "SCRIPT=%SCRIPT_DIR%\ecosystem-health.ps1"
set "LOGDIR=%SCRIPT_DIR%\logs"

if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>nul

rem Prefer PowerShell Core if available
set "PS=powershell.exe"
where pwsh >nul 2>nul && set "PS=pwsh"

rem Default iterations (override by setting ITERATIONS env var)
if "%ITERATIONS%"=="" set "ITERATIONS=3"

echo ======================================
echo   DEBUG LOOP: Ecosystem Health Check
echo ======================================
echo Script:     %SCRIPT%
echo Logs:       %LOGDIR%
echo Iterations: %ITERATIONS%
echo.

set "OVERALL=0"

rem Build a locale-independent timestamp (yyyyMMdd-HHmmss) using PowerShell.
rem Avoids the %DATE%/%TIME% format dependency that broke log filenames.
for /f "usebackq delims=" %%T in (`%PS% -NoProfile -Command "Get-Date -Format 'yyyyMMdd-HHmmss'"`) do set "RUN_TS=%%T"

for /L %%i in (1,1,%ITERATIONS%) do (
  set "LOGFILE=%LOGDIR%\ecosystem-health-run%%i-!RUN_TS!.log"

  echo --- Run %%i/%ITERATIONS% ---
  echo Logging to: !LOGFILE!

  rem Capture stdout+stderr to file
  %PS% -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %* > "!LOGFILE!" 2>&1

  if errorlevel 1 (
    echo [FAIL] Run %%i failed with exit code !ERRORLEVEL!
    set "OVERALL=1"
  ) else (
    echo [OK]   Run %%i succeeded
  )

  echo.
)

echo ======================================
echo   Debug loop complete (overall=%OVERALL%)
echo ======================================

endlocal & exit /b %OVERALL%
