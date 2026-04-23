@echo off
echo ==========================================
echo Loading SexFindR Docker Image
echo ==========================================
echo.
echo This will load the Docker image so you can run the pipeline.
echo Please wait, this may take a few minutes...
echo.

REM Check if Docker is running
docker ps >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running!
    echo.
    echo Please:
    echo 1. Open Docker Desktop
    echo 2. Wait until it says "Docker is running"
    echo 3. Run this script again
    echo.
    pause
    exit /b 1
)

REM Check if image file exists
if exist "sexfindr_image.tar" (
    echo Loading image from sexfindr_image.tar...
    docker load -i sexfindr_image.tar
    if errorlevel 1 (
        echo ERROR: Failed to load image
        pause
        exit /b 1
    )
    echo.
    echo Done! Image loaded successfully.
) else if exist "sexfindr_image.tar.gz" (
    echo Extracting and loading image...
    tar -xzf sexfindr_image.tar.gz
    docker load -i sexfindr_image.tar
    if errorlevel 1 (
        echo ERROR: Failed to load image
        pause
        exit /b 1
    )
    echo.
    echo Done! Image loaded successfully.
) else (
    echo ERROR: Docker image file not found!
    echo.
    echo Please make sure you have one of these files:
    echo   - sexfindr_image.tar
    echo   - sexfindr_image.tar.gz
    echo.
    echo If you have the image on Docker Hub, you can pull it instead:
    echo   docker pull yourusername/sexfindr:latest
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Success! You can now run the pipeline.
echo ==========================================
echo.
pause


