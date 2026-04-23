# Check if Docker is installed and ready

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Checking Docker Installation" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if docker command exists
$docker = Get-Command docker -ErrorAction SilentlyContinue

if ($docker) {
    Write-Host "Docker found at: $($docker.Source)" -ForegroundColor Green
    Write-Host ""
    
    # Check if Docker daemon is running
    Write-Host "Checking if Docker is running..." -ForegroundColor Yellow
    docker ps | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Docker is running!" -ForegroundColor Green
        Write-Host ""
        Write-Host "You can now build the image:" -ForegroundColor Yellow
        Write-Host "  docker build -t sexfindr:latest ." -ForegroundColor White
        Write-Host "  docker save -o sexfindr_image.tar sexfindr:latest" -ForegroundColor White
        Write-Host ""
        Write-Host "Or use the build script:" -ForegroundColor Yellow
        Write-Host "  powershell -ExecutionPolicy Bypass -File build_docker.ps1" -ForegroundColor White
    } else {
        Write-Host "Docker is installed but not running" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please:" -ForegroundColor Yellow
        Write-Host "  1. Open Docker Desktop" -ForegroundColor White
        Write-Host "  2. Wait until it says 'Docker Desktop is running'" -ForegroundColor White
        Write-Host "  3. Run this script again" -ForegroundColor White
    }
} else {
    Write-Host "Docker is NOT installed" -ForegroundColor Red
    Write-Host ""
    Write-Host "To build the Docker image, you need Docker Desktop:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Download Docker Desktop:" -ForegroundColor White
    Write-Host "   https://www.docker.com/products/docker-desktop" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2. Install Docker Desktop" -ForegroundColor White
    Write-Host "   (Follow the installation wizard)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Start Docker Desktop" -ForegroundColor White
    Write-Host "   (Wait until it says 'Docker Desktop is running')" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. Run this script again to verify" -ForegroundColor White
    Write-Host ""
    Write-Host "For detailed instructions, see: INSTALL_DOCKER_FIRST.md" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
