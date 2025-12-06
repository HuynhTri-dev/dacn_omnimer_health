@echo off
echo Starting OmniMer Health AI Server...
echo.

REM Change to the ai_server directory
cd /d "%~dp0"

REM Activate virtual environment if exists
if exist venv\Scripts\activate.bat (
    echo Activating virtual environment...
    call venv\Scripts\activate.bat
)

REM Run uvicorn from the ai_server directory
echo Starting uvicorn server...
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

pause
