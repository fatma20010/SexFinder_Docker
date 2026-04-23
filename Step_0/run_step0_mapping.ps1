# PowerShell script for Step 0: Mapping and Variant Calling
# This script maps FASTQ files to the reference genome using Bowtie2

param(
    [string]$ConfigFile = "..\config.sh"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "SexFindR - Step 0: Mapping and Variant Calling" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Load configuration (basic parsing for PowerShell)
$configContent = Get-Content $ConfigFile -Raw
$sexFindrDir = (Get-Location).Parent.FullName
$fastqDir = Join-Path $sexFindrDir "data\fastq"
$bamDir = Join-Path $sexFindrDir "data\bams"
$bowtie2Path = "C:\Users\msi\Downloads\bowtie2-2.5.5-mingw-x86_64\bowtie2-2.5.5-mingw-x86_64"
$bowtie2Index = Join-Path $sexFindrDir "data\bowtie2_index\Oikopleura_dioica"
$referenceGenome = Join-Path $sexFindrDir "ncbi_dataset\ncbi_dataset\data\GCA_907165135.1\GCA_907165135.1_OKI2018_I68_1.0_genomic.fna"
$maleSamples = Join-Path $sexFindrDir "Step_0\male_samples.txt"
$femaleSamples = Join-Path $sexFindrDir "Step_0\female_samples.txt"
$threads = 8

# Check if required files exist
if (-not (Test-Path $fastqDir)) {
    Write-Host "ERROR: FASTQ directory not found: $fastqDir" -ForegroundColor Red
    Write-Host "Please create the directory and add your FASTQ files." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path "$bowtie2Index.1.bt2")) {
    Write-Host "ERROR: Bowtie2 index not found: $bowtie2Index" -ForegroundColor Red
    Write-Host "Please create the index first." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path "$bowtie2Path\bowtie2.bat")) {
    Write-Host "ERROR: Bowtie2 not found at: $bowtie2Path" -ForegroundColor Red
    exit 1
}

# Check for samtools
$samtools = Get-Command samtools -ErrorAction SilentlyContinue
if (-not $samtools) {
    Write-Host "WARNING: samtools not found in PATH." -ForegroundColor Yellow
    Write-Host "BAM files will be created but not indexed." -ForegroundColor Yellow
    Write-Host "Install samtools or add it to PATH to enable indexing." -ForegroundColor Yellow
    Write-Host ""
}

# Create BAM output directory
New-Item -ItemType Directory -Force -Path $bamDir | Out-Null

# Function to map a single sample
function Map-Sample {
    param(
        [string]$SampleID,
        [string]$R1File,
        [string]$R2File
    )
    
    Write-Host "Mapping sample: $SampleID" -ForegroundColor Green
    Write-Host "  R1: $R1File" -ForegroundColor Gray
    Write-Host "  R2: $R2File" -ForegroundColor Gray
    
    $outputBam = Join-Path $bamDir "$SampleID.bam"
    
    # Build bowtie2 command
    $bowtie2Cmd = "& `"$bowtie2Path\bowtie2.bat`" -x `"$bowtie2Index`" -1 `"$R1File`" -2 `"$R2File`" -X 2000 -p $threads"
    
    Write-Host "  Running Bowtie2..." -ForegroundColor Yellow
    
    # Run bowtie2 and pipe to samtools
    if ($samtools) {
        # Full pipeline: bowtie2 -> samtools view -> samtools sort
        $sortBam = Join-Path $bamDir "$SampleID.sorted.bam"
        $bowtie2Output = Invoke-Expression $bowtie2Cmd 2>&1 | samtools view -b -S - 2>&1
        $bowtie2Output | samtools sort - -o $sortBam 2>&1
        Move-Item -Force $sortBam $outputBam
        samtools index $outputBam 2>&1
    } else {
        # Just run bowtie2 and save SAM output (user can convert later)
        $samOutput = Join-Path $bamDir "$SampleID.sam"
        Invoke-Expression "$bowtie2Cmd -S `"$samOutput`"" 2>&1
        Write-Host "  WARNING: SAM file created. Install samtools to convert to BAM." -ForegroundColor Yellow
    }
    
    if (Test-Path $outputBam) {
        Write-Host "  ✓ Successfully created: $outputBam" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Failed to create BAM file" -ForegroundColor Red
    }
    Write-Host ""
}

# Process male samples
if (Test-Path $maleSamples) {
    Write-Host "Processing male samples..." -ForegroundColor Cyan
    Write-Host ""
    
    $maleSampleList = Get-Content $maleSamples | Where-Object { $_ -notmatch '^#' -and $_ -match '\S' }
    
    foreach ($sample in $maleSampleList) {
        $sample = $sample.Trim()
        $r1File = Join-Path $fastqDir "${sample}_R1.fastq"
        $r2File = Join-Path $fastqDir "${sample}_R2.fastq"
        
        # Try different naming conventions
        if (-not (Test-Path $r1File)) {
            $r1File = Join-Path $fastqDir "${sample}_1.fastq"
            $r2File = Join-Path $fastqDir "${sample}_2.fastq"
        }
        if (-not (Test-Path $r1File)) {
            $r1File = Join-Path $fastqDir "${sample}.R1.fastq"
            $r2File = Join-Path $fastqDir "${sample}.R2.fastq"
        }
        
        if ((Test-Path $r1File) -and (Test-Path $r2File)) {
            Map-Sample -SampleID $sample -R1File $r1File -R2File $r2File
        } else {
            Write-Host "WARNING: FASTQ files not found for sample: $sample" -ForegroundColor Yellow
            Write-Host "  Expected: $r1File and $r2File" -ForegroundColor Gray
            Write-Host ""
        }
    }
}

# Process female samples
if (Test-Path $femaleSamples) {
    Write-Host "Processing female samples..." -ForegroundColor Cyan
    Write-Host ""
    
    $femaleSampleList = Get-Content $femaleSamples | Where-Object { $_ -notmatch '^#' -and $_ -match '\S' }
    
    foreach ($sample in $femaleSampleList) {
        $sample = $sample.Trim()
        $r1File = Join-Path $fastqDir "${sample}_R1.fastq"
        $r2File = Join-Path $fastqDir "${sample}_R2.fastq"
        
        # Try different naming conventions
        if (-not (Test-Path $r1File)) {
            $r1File = Join-Path $fastqDir "${sample}_1.fastq"
            $r2File = Join-Path $fastqDir "${sample}_2.fastq"
        }
        if (-not (Test-Path $r1File)) {
            $r1File = Join-Path $fastqDir "${sample}.R1.fastq"
            $r2File = Join-Path $fastqDir "${sample}.R2.fastq"
        }
        
        if ((Test-Path $r1File) -and (Test-Path $r2File)) {
            Map-Sample -SampleID $sample -R1File $r1File -R2File $r2File
        } else {
            Write-Host "WARNING: FASTQ files not found for sample: $sample" -ForegroundColor Yellow
            Write-Host "  Expected: $r1File and $r2File" -ForegroundColor Gray
            Write-Host ""
        }
    }
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Step 0 Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "BAM files created in: $bamDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next step: Run Step 1 (DifCover analysis)" -ForegroundColor Yellow
Write-Host "  cd Step_1" -ForegroundColor White
Write-Host "  bash run_difcover.sh <male_bam> <female_bam> <adjustment_coefficient>" -ForegroundColor White





