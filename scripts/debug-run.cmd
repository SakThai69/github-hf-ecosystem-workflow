@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

set "SCRIPT=%SCRIPT_DIR%\ecosystem-health.ps1"

rem Choose PowerShell engine
set "PS=powershell.exe"
where pwsh >nul 2>nul && set "PS=pwsh"

rem Default iterations
set ITERATIONS=3

echo ======================================
echo   DEBUG LOOP: Ecosystem Health Check
echo ======================================
echo.

for /L %%i in (1,1,%ITERATIONS%) do (
    echo --- Run %%i/%ITERATIONS% ---

    %PS% -NoProfile -ExecutionPolicy Bypass ^
        -File "%SCRIPT%" -Json %*

    if errorlevel 1 (
        echo [FAIL] Run %%i failed with exit code %ERRORLEVEL%
    ) else (
        echo [OK]   Run %%i succeeded
    )

    echo.
)

echo ======================================
echo   Debug loop complete
echo ======================================

endlocal
``
