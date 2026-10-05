@echo off
rem Start the Hugo dev server for this blog (run from anywhere; paths are resolved relative to this file)
cd /d "%~dp0.."

set "HUGO_WINGET=C:\Users\wu-ji\AppData\Local\Microsoft\WinGet\Packages\Hugo.Hugo.Extended_Microsoft.Winget.Source_8wekyb3d8bbwe\hugo.exe"

where hugo >nul 2>nul
if %errorlevel%==0 (
    hugo server
) else if exist "%HUGO_WINGET%" (
    echo hugo not on PATH, using winget install: %HUGO_WINGET%
    "%HUGO_WINGET%" server
) else (
    echo ERROR: hugo.exe not found. Install with: winget install Hugo.Hugo.Extended
    exit /b 1
)
