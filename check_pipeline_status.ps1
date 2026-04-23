# Pipeline Status Check Script
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "SexFindR Pipeline - Status Check" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$allReady = $true

# Check 1: Configuration
Write-Host "1. Configuration Files:" -ForegroundColor Yellow
if (Test-Path "config.sh") {
    Write-Host "   ✓ config.sh exists" -ForegroundColor Green
} else {
    Write-Host "   ✗ config.sh missing" -ForegroundColor Red
    $allReady = $false
}
Write-Host ""

# Check 2: Reference Genome
Write-Host "2. Reference Genome:" -ForegroundColor Yellow
$refGenome = "ncbi_dataset\ncbi_dataset\data\GCA_907165135.1\GCA_907165135.1_OKI2018_I68_1.0_genomic.fna"
if (Test-Path $refGenome) {
    $size = (Get-Item $refGenome).Length / 1MB
    Write-Host "   ✓ Reference genome found ($([math]::Round($size, 2)) MB)" -ForegroundColor Green
} else {
    Write-Host "   ✗ Reference genome missing" -ForegroundColor Red
    $allReady = $false
}
Write-Host ""

# Check 3: Bowtie2 Index
Write-Host "3. Bowtie2 Index:" -ForegroundColor Yellow
$indexFile = "data\bowtie2_index\Oikopleura_dioica.1.bt2"
if (Test-Path $indexFile) {
    Write-Host "   ✓ Bowtie2 index created" -ForegroundColor Green
} else {
    Write-Host "   ✗ Bowtie2 index missing" -ForegroundColor Red
    $allReady = $false
}
Write-Host ""

# Check 4: Bowtie2 Installation
Write-Host "4. Bowtie2:" -ForegroundColor Yellow
$bowtie2Path = "C:\Users\msi\Downloads\bowtie2-2.5.5-mingw-x86_64\bowtie2-2.5.5-mingw-x86_64\bowtie2.bat"
if (Test-Path $bowtie2Path) {
    Write-Host "   ✓ Bowtie2 installed" -ForegroundColor Green
} else {
    Write-Host "   ✗ Bowtie2 not found" -ForegroundColor Red
    $allReady = $false
}
Write-Host ""

# Check 5: DifCover
Write-Host "5. DifCover:" -ForegroundColor Yellow
$difcoverPath = "C:\Users\msi\DifCover\dif_cover_scripts"
if (Test-Path $difcoverPath) {
    Write-Host "   ✓ DifCover installed" -ForegroundColor Green
} else {
    Write-Host "   ✗ DifCover missing" -ForegroundColor Red
    $allReady = $false
}
Write-Host ""

# Check 6: R Packages
Write-Host "6. R Packages:" -ForegroundColor Yellow
$rscript = Get-Command Rscript -ErrorAction SilentlyContinue
if ($rscript) {
    Write-Host "   ✓ Rscript found" -ForegroundColor Green
    Write-Host "   (R packages should be installed)" -ForegroundColor Gray
} else {
    Write-Host "   ⚠ Rscript not in PATH (but R may still work)" -ForegroundColor Yellow
}
Write-Host ""

# Check 7: SAMtools
Write-Host "7. SAMtools:" -ForegroundColor Yellow
$samtools = Get-Command samtools -ErrorAction SilentlyContinue
if ($samtools) {
    Write-Host "   ✓ SAMtools installed" -ForegroundColor Green
} else {
    Write-Host "   ⚠ SAMtools not found (recommended but not required)" -ForegroundColor Yellow
    Write-Host "   Install with: conda install -c bioconda samtools" -ForegroundColor Gray
}
Write-Host ""

# Check 8: Data Directories
Write-Host "8. Data Directories:" -ForegroundColor Yellow
$fastqDir = "data\fastq"
$bamDir = "data\bams"
$vcfDir = "data\vcfs"

if (Test-Path $fastqDir) {
    $fastqCount = (Get-ChildItem $fastqDir -ErrorAction SilentlyContinue | Measure-Object).Count
    if ($fastqCount -gt 0) {
        Write-Host "   ✓ FASTQ directory has $fastqCount file(s)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ FASTQ directory empty (add your FASTQ files here)" -ForegroundColor Yellow
        $allReady = $false
    }
} else {
    Write-Host "   ✗ FASTQ directory missing" -ForegroundColor Red
    $allReady = $false
}

if (Test-Path $bamDir) {
    Write-Host "   ✓ BAM directory exists" -ForegroundColor Green
} else {
    Write-Host "   ✗ BAM directory missing" -ForegroundColor Red
    $allReady = $false
}

if (Test-Path $vcfDir) {
    Write-Host "   ✓ VCF directory exists" -ForegroundColor Green
} else {
    Write-Host "   ✗ VCF directory missing" -ForegroundColor Red
    $allReady = $false
}
Write-Host ""

# Check 9: Sample Lists
Write-Host "9. Sample Lists:" -ForegroundColor Yellow
$maleSamples = "Step_0\male_samples.txt"
$femaleSamples = "Step_0\female_samples.txt"

if (Test-Path $maleSamples) {
    $maleContent = Get-Content $maleSamples | Where-Object { $_ -notmatch '^#' -and $_ -match '\S' }
    if ($maleContent.Count -gt 0) {
        Write-Host "   ✓ Male samples: $($maleContent.Count) sample(s)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Male samples list is empty (add sample IDs)" -ForegroundColor Yellow
        $allReady = $false
    }
} else {
    Write-Host "   ✗ Male samples file missing" -ForegroundColor Red
    $allReady = $false
}

if (Test-Path $femaleSamples) {
    $femaleContent = Get-Content $femaleSamples | Where-Object { $_ -notmatch '^#' -and $_ -match '\S' }
    if ($femaleContent.Count -gt 0) {
        Write-Host "   ✓ Female samples: $($femaleContent.Count) sample(s)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Female samples list is empty (add sample IDs)" -ForegroundColor Yellow
        $allReady = $false
    }
} else {
    Write-Host "   ✗ Female samples file missing" -ForegroundColor Red
    $allReady = $false
}
Write-Host ""

# Summary
Write-Host "==========================================" -ForegroundColor Cyan
if ($allReady) {
    Write-Host "Status: READY TO RUN!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now run Step 0:" -ForegroundColor Yellow
    Write-Host "  cd Step_0" -ForegroundColor White
    Write-Host "  powershell -ExecutionPolicy Bypass -File run_step0_mapping.ps1" -ForegroundColor White
} else {
    Write-Host "Status: NOT READY YET" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Missing items:" -ForegroundColor Yellow
    Write-Host "  - Add FASTQ files to data\fastq\" -ForegroundColor White
    Write-Host "  - Add sample IDs to Step_0\male_samples.txt" -ForegroundColor White
    Write-Host "  - Add sample IDs to Step_0\female_samples.txt" -ForegroundColor White
    Write-Host "  - Install SAMtools (recommended): conda install -c bioconda samtools" -ForegroundColor White
}
Write-Host "==========================================" -ForegroundColor Cyan


