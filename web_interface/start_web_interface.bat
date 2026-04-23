@echo off
echo ==========================================
echo Starting SexFindR Web Interface
echo ==========================================
echo.

REM Check if Docker is running
echo Checking Docker Desktop...
docker ps >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Docker Desktop is not running!
    echo.
    echo Please:
    echo 1. Open Docker Desktop from Start menu
    echo 2. Wait until it says "Docker is running" (green icon)
    echo 3. Then run this script again
    echo.
    echo Opening Docker Desktop for you...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    echo.
    echo Waiting 30 seconds for Docker to start...
    timeout /t 30 /nobreak
    echo.
)

REM Check again
docker ps >nul 2>&1
if errorlevel 1 (
    echo Docker is still not running. Please start Docker Desktop manually.
    pause
    exit /b 1
)

echo Docker is running!
echo.

REM Navigate to web_interface directory
cd /d "%~dp0"

echo Starting web interface containers...
docker-compose up -d

if errorlevel 1 (
    echo.
    echo ERROR: Failed to start containers!
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Web Interface Started!
echo ==========================================
echo.
echo Containers are starting...
timeout /t 5 /nobreak

echo.
echo Opening web interface in browser...
start http://localhost

echo.
echo Web interface should be available at:
echo   http://localhost
echo.
echo To stop the interface:
echo   docker-compose down
echo.
pause



