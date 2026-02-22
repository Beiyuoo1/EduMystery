@echo off
echo Starting EduMys web server...
echo.

:: Start the Python server in the background
start "" python serve_web.py

:: Wait 3 seconds for the server to start and copy audio files
timeout /t 3 /nobreak >nul

:: Open Chrome at localhost:8080
:: Try common Chrome installation paths
set CHROME=
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set CHROME="C:\Program Files\Google\Chrome\Application\chrome.exe"
) else if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    set CHROME="C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
)

if defined CHROME (
    echo Opening Chrome at http://localhost:8080...
    start "" %CHROME% --new-tab http://localhost:8080
) else (
    echo Chrome not found at default locations. Opening with default browser...
    start http://localhost:8080
)

echo.
echo Server is running. Close this window to stop the server.
echo (The server will keep running in the background window)
pause
