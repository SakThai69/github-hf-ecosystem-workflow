@echo off
setlocal
set "HF_FALLBACK=%USERPROFILE%\AppData\Roaming\Python\Python314\Scripts\hf.exe"

if exist "%HF_FALLBACK%" (
  "%HF_FALLBACK%" %*
  exit /b %ERRORLEVEL%
)

where hf >nul 2>nul
if %ERRORLEVEL%==0 (
  hf %*
  exit /b %ERRORLEVEL%
)

echo ERROR: Hugging Face CLI not found.
echo Tried fallback: %HF_FALLBACK%
echo Install or expose hf on PATH, then retry.
exit /b 1
