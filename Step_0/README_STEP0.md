# Step 0: Mapping and Variant Calling - Instructions

## Overview
Step 0 maps your raw FASTQ sequencing reads to the reference genome using Bowtie2, creating BAM files that will be used in subsequent steps.

## Prerequisites
- ✅ FASTQ files placed in `data/fastq/`
- ✅ Sample IDs listed in `male_samples.txt` and `female_samples.txt`
- ✅ Bowtie2 index created (already done)
- ✅ Bowtie2 installed (already done)
- ⚠️ SAMtools (recommended for BAM file creation and indexing)

## File Naming Convention

Your FASTQ files should follow one of these naming patterns:
- `sample_name_R1.fastq` and `sample_name_R2.fastq` (recommended)
- `sample_name_1.fastq` and `sample_name_2.fastq`
- `sample_name.R1.fastq` and `sample_name.R2.fastq`

The sample name must match the IDs in your sample list files.

## Running Step 0

### Option 1: Using PowerShell Script (Windows - Recommended)

```powershell
cd C:\Users\msi\SexFindR\Step_0
powershell -ExecutionPolicy Bypass -File run_step0_mapping.ps1
```

### Option 2: Manual Mapping (if you prefer)

For each sample, run:
```powershell
# Example for a single sample
cd C:\Users\msi\SexFindR

# Map reads
& "C:\Users\msi\Downloads\bowtie2-2.5.5-mingw-x86_64\bowtie2-2.5.5-mingw-x86_64\bowtie2.bat" `
  -x "data\bowtie2_index\Oikopleura_dioica" `
  -1 "data\fastq\sample_R1.fastq" `
  -2 "data\fastq\sample_R2.fastq" `
  -X 2000 -p 8 | samtools view -b -S - | samtools sort - -o "data\bams\sample.bam"

# Index BAM file
samtools index "data\bams\sample.bam"
```

### Option 3: Using Git Bash/WSL (Linux-style scripts)

If you have Git Bash or WSL:
```bash
cd Step_0
bash bowtie2_16_linux.sh sample_R1.fastq sample_R2.fastq ../data/bowtie2_index/Oikopleura_dioica
```

## Output

After running Step 0, you should have:
- BAM files in `data/bams/` (one per sample)
- BAM index files (`.bai`) if samtools is installed

## Troubleshooting

### FASTQ files not found
- Check that files are in `data/fastq/`
- Verify file names match sample IDs in list files
- Check file naming convention matches one of the supported patterns

### Bowtie2 not found
- Verify Bowtie2 is at: `C:\Users\msi\Downloads\bowtie2-2.5.5-mingw-x86_64\bowtie2-2.5.5-mingw-x86_64\`
- Or update the path in `run_step0_mapping.ps1`

### SAMtools not found
- Install SAMtools: `conda install -c bioconda samtools`
- Or download from: http://www.htslib.org/download/
- BAM files can still be created manually if needed

### Low mapping rate
- Check that your FASTQ files match the reference genome species
- Verify reference genome is correct (Oikopleura dioica)
- Check FASTQ file quality

## Next Steps

After Step 0 completes successfully:
1. Verify BAM files are created in `data/bams/`
2. Proceed to Step 1: Coverage-based analysis (DifCover)
3. You'll need at least one male and one female BAM file for Step 1





