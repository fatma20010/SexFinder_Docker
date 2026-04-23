# PowerShell script to install R dependencies for SexFindR
# Run this script from PowerShell: .\install_dependencies.ps1

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "SexFindR - Installing R Dependencies" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Rscript is installed
$rscriptPath = Get-Command Rscript -ErrorAction SilentlyContinue

# If not in PATH, try common Windows installation locations
if (-not $rscriptPath) {
    $commonPaths = @(
        "C:\Program Files\R\*\bin\Rscript.exe",
        "C:\Program Files (x86)\R\*\bin\Rscript.exe"
    )
    
    foreach ($pathPattern in $commonPaths) {
        $found = Get-ChildItem -Path $pathPattern -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $rscriptPath = @{Source = $found.FullName}
            break
        }
    }
}

if (-not $rscriptPath) {
    Write-Host "ERROR: Rscript is not found in PATH or common installation locations." -ForegroundColor Red
    Write-Host "Please install R from https://cran.r-project.org/" -ForegroundColor Yellow
    Write-Host "Or add R to your PATH environment variable." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "After installing R, make sure to add the R bin directory to your PATH:" -ForegroundColor Yellow
    Write-Host "  Example: C:\Program Files\R\R-4.x.x\bin" -ForegroundColor Gray
    exit 1
}

$rscriptExe = if ($rscriptPath.Source) { $rscriptPath.Source } else { "Rscript" }
Write-Host "Rscript found at: $rscriptExe" -ForegroundColor Green
Write-Host ""

# Read required packages
$packages = Get-Content "requirements_R.txt" | Where-Object { $_ -notmatch '^#' -and $_ -match '\S' }

Write-Host "Installing R packages:" -ForegroundColor Yellow
foreach ($pkg in $packages) {
    Write-Host "  - $pkg" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Installing packages..." -ForegroundColor Yellow

# Create R installation script - use single quotes to avoid PowerShell variable expansion
$packageList = ($packages | ForEach-Object { "'$_'" }) -join ', '
$rScript = @'
# Set up user library directory
user_lib <- Sys.getenv('R_LIBS_USER')
if(user_lib == '') {
    # Default Windows user library location - use R.Version() to get version
    r_ver <- R.Version()
    r_version <- paste(r_ver$major, strsplit(r_ver$minor, '.')[[1]][1], sep='.')
    user_lib <- file.path(Sys.getenv('USERPROFILE'), 'Documents', 'R', 'win-library', r_version)
}
if(!dir.exists(user_lib)) {
    dir.create(user_lib, recursive=TRUE)
}
.libPaths(c(user_lib, .libPaths()))
cat('Using library path:', user_lib, '\n')

packages <- c(@packageList@)
new_packages <- packages[!(packages %in% installed.packages()[,'Package'])]
if(length(new_packages)) {
    cat('Installing', length(new_packages), 'new package(s)...\n')
    install.packages(new_packages, repos='https://cran.rstudio.com/', lib=user_lib)
} else {
    cat('All packages are already installed.\n')
}
cat('Checking installation...\n')
for(pkg in packages) {
    if(require(pkg, character.only=TRUE, quietly=TRUE)) {
        cat('OK:', pkg, '\n')
    } else {
        cat('FAILED:', pkg, '\n')
    }
}
'@ -replace '@packageList@', $packageList

$rScript | Out-File -FilePath "install_packages.R" -Encoding ASCII

# Run R script
Write-Host ""
& $rscriptExe install_packages.R

# Clean up
Remove-Item "install_packages.R" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Configure config.sh (copy from config_template.sh)" -ForegroundColor White
Write-Host "2. Install bioinformatics tools (bowtie2, samtools, etc.)" -ForegroundColor White
Write-Host "3. Install DifCover from https://github.com/genome/difcover" -ForegroundColor White
Write-Host "4. See SETUP.md for detailed instructions" -ForegroundColor White

