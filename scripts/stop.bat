@echo off
rem Stop the Hugo dev server for this blog (kills whatever listens on port 1313)

set "FOUND="
for /f "tokens=5" %%p in ('netstat -ano ^| findstr /r ":1313 .*LISTENING"') do (
    set "FOUND=1"
    echo Stopping hugo server, PID %%p
    taskkill /PID %%p /F >nul
)
if not defined FOUND echo Hugo server is not running on port 1313.
