@echo off
REM Clue Analyzer - Windows Batch File
REM Double-click this file to run the analyzer

echo Starting Clue Analyzer...
python clue_analyzer.py %*

REM Keep window open if there's an error
if errorlevel 1 (
    echo.
    echo Error: Python may not be installed or not in PATH
    echo Please install Python from https://www.python.org/
    pause
)
