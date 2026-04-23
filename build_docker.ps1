# PowerShell script to build Docker image for SexFindR

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Building SexFindR Docker Image" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is installed
$docker = Get-Command docker -ErrorAction SilentlyContinue
if (-not $docker) {
    Write-Host "ERROR: Docker is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

Write-Host "Docker found. Building image..." -ForegroundColor Green
Write-Host ""

# Build the image
Write-Host "Building image: sexfindr:latest" -ForegroundColor Yellow
docker build -t sexfindr:latest .

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Build Successful!" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Show image info
    Write-Host "Image created: sexfindr:latest" -ForegroundColor Green
    docker images sexfindr:latest
    Write-Host ""
    
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Test the image:" -ForegroundColor White
    Write-Host "   docker run -it --rm sexfindr:latest bash" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Save the image to share:" -ForegroundColor White
    Write-Host "   docker save -o sexfindr_image.tar sexfindr:latest" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Or push to Docker Hub:" -ForegroundColor White
    Write-Host "   docker tag sexfindr:latest yourusername/sexfindr:latest" -ForegroundColor Gray
    Write-Host "   docker push yourusername/sexfindr:latest" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. Share DOCKER_README.md with your professor" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Build Failed!" -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Check the error messages above." -ForegroundColor Yellow
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  - Docker daemon not running" -ForegroundColor White
    Write-Host "  - Insufficient disk space" -ForegroundColor White
    Write-Host "  - Network issues (downloading packages)" -ForegroundColor White
    exit 1
}


