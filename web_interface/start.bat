@echo off
echo ==========================================
echo SexFindR Web Interface - Quick Start
echo ==========================================
echo.

REM Check if Docker is running
docker ps >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running!
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)

REM Check if sexfindr image exists
docker images sexfindr:latest | findstr sexfindr >nul 2>&1
if errorlevel 1 (
    echo WARNING: sexfindr:latest image not found!
    echo Please load the Docker image first:
    echo   docker load -i ..\sexfindr_image.tar
    echo.
    pause
)

REM Start services
echo Starting web interface...
docker-compose up -d

echo.
echo ==========================================
echo Web Interface Started!
echo ==========================================
echo.
echo Access the interface at:
echo   http://localhost
echo.
echo Backend API at:
echo   http://localhost:5000
echo.
echo To stop the interface:
echo   docker-compose down
echo.
pause




