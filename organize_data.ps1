# PowerShell script to help organize data files for SexFindR pipeline
# This script helps you identify and organize your sequencing data

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "SexFindR - Data Organization Helper" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check what data files exist
Write-Host "Searching for data files..." -ForegroundColor Yellow
Write-Host ""

$fastqFiles = Get-ChildItem -Path "C:\Users\msi" -Recurse -Include *.fastq,*.fq,*.fastq.gz,*.fq.gz -ErrorAction SilentlyContinue -Depth 3 | Select-Object -First 10
$bamFiles = Get-ChildItem -Path "C:\Users\msi" -Recurse -Include *.bam -ErrorAction SilentlyContinue -Depth 3 | Select-Object -First 10
$vcfFiles = Get-ChildItem -Path "C:\Users\msi" -Recurse -Include *.vcf,*.vcf.gz -ErrorAction SilentlyContinue -Depth 3 | Select-Object -First 10

Write-Host "Found Files:" -ForegroundColor Green
Write-Host ""

if ($fastqFiles) {
    Write-Host "FASTQ Files found:" -ForegroundColor Green
    $fastqFiles | ForEach-Object { Write-Host "  - $($_.FullName)" -ForegroundColor Gray }
    Write-Host ""
    Write-Host "To organize FASTQ files:" -ForegroundColor Yellow
    Write-Host "  1. Copy them to: C:\Users\msi\SexFindR\data\fastq\" -ForegroundColor White
    Write-Host "  2. Use naming: sample_name_R1.fastq and sample_name_R2.fastq" -ForegroundColor White
    Write-Host "  3. Start with Step 0 (Mapping)" -ForegroundColor White
    Write-Host ""
}

if ($bamFiles) {
    Write-Host "BAM Files found:" -ForegroundColor Green
    $bamFiles | ForEach-Object { Write-Host "  - $($_.FullName)" -ForegroundColor Gray }
    Write-Host ""
    Write-Host "To organize BAM files:" -ForegroundColor Yellow
    Write-Host "  1. Copy them to: C:\Users\msi\SexFindR\data\bams\" -ForegroundColor White
    Write-Host "  2. Use naming: sample_name.bam" -ForegroundColor White
    Write-Host "  3. Start with Step 1 (DifCover)" -ForegroundColor White
    Write-Host ""
}

if ($vcfFiles) {
    Write-Host "VCF Files found:" -ForegroundColor Green
    $vcfFiles | ForEach-Object { Write-Host "  - $($_.FullName)" -ForegroundColor Gray }
    Write-Host ""
    Write-Host "To organize VCF files:" -ForegroundColor Yellow
    Write-Host "  1. Copy them to: C:\Users\msi\SexFindR\data\vcfs\" -ForegroundColor White
    Write-Host "  2. Start with Step 2 (Sequence Analysis)" -ForegroundColor White
    Write-Host ""
}

if (-not $fastqFiles -and -not $bamFiles -and -not $vcfFiles) {
    Write-Host "No data files found in common locations." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please provide the location of your data files, or:" -ForegroundColor Yellow
    Write-Host "  1. Download data from NCBI SRA or other sources" -ForegroundColor White
    Write-Host "  2. Place files in the appropriate directory:" -ForegroundColor White
    Write-Host "     - FASTQ files → data\fastq\" -ForegroundColor Gray
    Write-Host "     - BAM files → data\bams\" -ForegroundColor Gray
    Write-Host "     - VCF files → data\vcfs\" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Copy your data files to the appropriate directory" -ForegroundColor White
Write-Host "2. Edit Step_0/male_samples.txt with your male sample IDs" -ForegroundColor White
Write-Host "3. Edit Step_0/female_samples.txt with your female sample IDs" -ForegroundColor White
Write-Host "4. Run the appropriate pipeline step based on your data type" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Cyan





