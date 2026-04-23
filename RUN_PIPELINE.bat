@echo off
echo ==========================================
echo SexFindR Pipeline - Easy Runner
echo ==========================================
echo.

REM Check if Docker is running
docker ps >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running!
    echo.
    echo Please open Docker Desktop and wait until it says "Docker is running"
    echo Then run this script again.
    echo.
    pause
    exit /b 1
)

REM Check if image exists
docker images sexfindr:latest | findstr sexfindr >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker image not found!
    echo.
    echo Please run LOAD_DOCKER.bat first to load the image.
    echo.
    pause
    exit /b 1
)

echo Starting pipeline...
echo.
echo This will:
echo 1. Check your data files
echo 2. Run the appropriate pipeline step
echo 3. Save results to the output folder
echo.
echo Please wait, this may take a while...
echo.

REM Create output directory
if not exist "output" mkdir output

REM Check what type of data they have
set DATA_TYPE=unknown
if exist "data\fastq\*.fastq" set DATA_TYPE=fastq
if exist "data\fastq\*.fq" set DATA_TYPE=fastq
if exist "data\bams\*.bam" set DATA_TYPE=bam
if exist "data\vcfs\*.vcf" set DATA_TYPE=vcf

if "%DATA_TYPE%"=="unknown" (
    echo WARNING: No data files found!
    echo.
    echo Please add your data files to:
    echo   - data\fastq\  (for FASTQ files)
    echo   - data\bams\   (for BAM files)
    echo   - data\vcfs\   (for VCF files)
    echo.
    pause
    exit /b 1
)

echo Detected data type: %DATA_TYPE%
echo.

REM Run the appropriate step
if "%DATA_TYPE%"=="fastq" (
    echo Running Step 0: Mapping FASTQ files...
    docker run --rm -v "%CD%\data:/sexfindr/data" -v "%CD%\output:/sexfindr/output" -v "%CD%\Step_0:/sexfindr/Step_0" -v "%CD%\config.sh:/sexfindr/config.sh" sexfindr:latest bash -c "cd /sexfindr/Step_0 && bash run_step0_mapping.sh"
) else if "%DATA_TYPE%"=="bam" (
    echo Running Step 1: DifCover analysis...
    echo.
    echo NOTE: You need to specify which BAM files to compare.
    echo Please edit RUN_STEP1.bat with your BAM file names.
    echo.
    pause
    exit /b 0
) else if "%DATA_TYPE%"=="vcf" (
    echo Running Step 2: Sequence analysis...
    docker run --rm -v "%CD%\data:/sexfindr/data" -v "%CD%\output:/sexfindr/output" -v "%CD%\Step_2:/sexfindr/Step_2" -v "%CD%\config.sh:/sexfindr/config.sh" sexfindr:latest bash -c "cd /sexfindr/Step_2 && echo 'Step 2 analysis - see SETUP.md for details'"
)

if errorlevel 1 (
    echo.
    echo ERROR: Pipeline failed!
    echo Check the error messages above.
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Pipeline Complete!
echo ==========================================
echo.
echo Results are saved in the 'output' folder.
echo.
pause





