@echo off
title MP3 Volume Booster

REM Check if python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found. Please install Python 3.8+
    pause
    exit /b 1
)

REM Check if ffmpeg is available
where ffmpeg >nul 2>&1
if errorlevel 1 (
    echo ffmpeg not found - installing via winget...
    winget install --id Gyan.FFmpeg -e --accept-source-agreements --accept-package-agreements --silent
    if errorlevel 1 (
        echo.
        echo WARNING: Could not auto-install ffmpeg.
        echo Please install manually:  winget install ffmpeg
        echo.
        pause
    ) else (
        echo ffmpeg installed successfully. Please restart this batch file.
        pause
        exit /b 0
    )
)

REM Launch the tool (pass any dragged-and-dropped files as arguments)
python "%~dp0mp3_volume_booster.py" %*
if errorlevel 1 pause
