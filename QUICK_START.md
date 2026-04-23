# Quick Start Guide - Running SexFindR Pipeline

## Current Setup Status ✅

- ✅ R packages installed (tidyverse, patchwork, ggpubr, ggthemes)
- ✅ DifCover downloaded and configured
- ✅ Reference genome: Oikopleura dioica (OKI2018_I68_1.0)
- ✅ Bowtie2 index created
- ✅ Data directories created (data/fastq, data/bams, data/vcfs)
- ✅ Sample list files created (Step_0/male_samples.txt, Step_0/female_samples.txt)

## What Data Do You Have?

The pipeline can start at different steps depending on your data:

### Option A: You have FASTQ files (raw sequencing reads)
- Place your FASTQ files in: `data/fastq/`
- Format: `sample_name_R1.fastq` and `sample_name_R2.fastq` (for paired-end)
- Start with **Step 0**: Mapping and variant calling
### Option B: You have BAM files (already aligned)
- Place your BAM files in: `data/bams/`
- Format: `sample_name.bam`
- Start with **Step 1**: Coverage-based analysis (DifCover)

### Option C: You have VCF files (already called variants)
- Place your VCF files in: `data/vcfs/`
- Start with **Step 2**: Sequence-based analyses

## Next Steps

### 1. Add Your Sample IDs

Edit these files with your actual sample IDs (one per line, no comments):

**Step_0/male_samples.txt:**
```
male_sample_1
male_sample_2
male_sample_3
```

**Step_0/female_samples.txt:**
```
female_sample_1
female_sample_2
female_sample_3
```

### 2. Place Your Data Files

Copy your data files to the appropriate directory:
- FASTQ files → `data/fastq/`
- BAM files → `data/bams/`
- VCF files → `data/vcfs/`

### 3. Run the Pipeline

The pipeline runs in 4 steps. You can run them individually or use the main script.

**To run individual steps, see SETUP.md for detailed instructions.**

**To check pipeline status:**
```bash
bash run_pipeline.sh
```

## Important Notes

- Make sure your sample IDs in the list files match your file names
- BAM files should be sorted and indexed (use `samtools sort` and `samtools index`)
- The pipeline expects specific file naming conventions - check SETUP.md for details

