@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: hf-safe.cmd - Safe Hugging Face CLI wrapper
:: Resolves `hf.exe` from a known list of Python user-scripts paths first,
:: then falls back to PATH. Never stores or prints tokens. Passes all
:: arguments through unchanged.

set "HF_BIN="

:: 1) Try common Python user-scripts paths (newest versions first)
for %%V in (Python314 Python313 Python312 Python311 Python310) do (
  set "CANDIDATE=%USERPROFILE%\AppData\Roaming\Python\%%V\Scripts\hf.exe"
  if exist "!CANDIDATE!" (
    set "HF_BIN=!CANDIDATE!"
    goto :run
  )
)

:: 2) Try hf on PATH
where hf >nul 2>nul
if %ERRORLEVEL%==0 (
  set "HF_BIN=hf"
  goto :run
)

:: Nothing found - give actionable error
echo.
echo ERROR: Hugging Face CLI not found.
echo.
echo   Tried these absolute paths:
for %%V in (Python314 Python313 Python312 Python311 Python310) do (
  echo     %USERPROFILE%\AppData\Roaming\Python\%%V\Scripts\hf.exe
)
echo     hf on PATH
echo.
echo   To install:
echo     python -m pip install --upgrade "huggingface_hub[cli]"
echo.
echo   Then re-run this script or add the Scripts directory to your PATH.
echo.

:: Warn if HF_TOKEN is missing too - common root cause
if not defined HF_TOKEN (
  echo   Note: HF_TOKEN environment variable is also not set.
  echo   Set it with:  set HF_TOKEN=your_read_only_token
  echo.
)

exit /b 1

:run
:: Warn (but don't block) if HF_TOKEN is unset - auth may still work via stored login
if not defined HF_TOKEN (
  echo [WARN] HF_TOKEN is not set in this shell. Falling back to stored hf auth login credentials.
  echo        If auth fails, run: hf auth login   or   set HF_TOKEN=^<token^>
  echo.
)

"%HF_BIN%" %*
exit /b %ERRORLEVEL%
