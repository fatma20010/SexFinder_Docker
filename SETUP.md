# SexFindR Pipeline Setup Guide

This guide will help you set up and run the SexFindR pipeline for sex chromosome identification.

## Overview

SexFindR is a computational workflow to identify young and old sex chromosomes. The pipeline consists of 4 main steps:

- **Step 0**: Mapping and variant calling
- **Step 1**: Coverage-based analysis (DifCover)
- **Step 2**: Sequence-based analyses (Fst, GWAS, k-mer GWAS, SNP Density)
- **Step 3**: Combined sequence-based analysis

## Prerequisites

### Required Software

1. **Bioinformatics Tools:**
   - [Bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml) - for read mapping
   - [SAMtools](http://www.htslib.org/) - for BAM file manipulation
   - [VCFtools](https://vcftools.github.io/) - for VCF file processing
   - [PLINK](https://www.cog-genomics.org/plink/) - for GWAS analysis
   - [GEMMA](https://github.com/genetics-statistics/GEMMA) - for association testing
   - [DifCover](https://github.com/genome/difcover) - for coverage difference analysis

2. **Programming Languages:**
   - **R** (version 3.6+ recommended)
   - **Python** (version 3.6+)
   - **Bash** (for shell scripts)

### R Packages

Install required R packages:

```bash
Rscript -e "install.packages(c('tidyverse', 'patchwork', 'ggpubr', 'ggthemes'), repos='https://cran.rstudio.com/')"
```

Or use the requirements file:

```bash
Rscript -e "install.packages(readLines('requirements_R.txt'), repos='https://cran.rstudio.com/')"
```

### Python

Python scripts use only standard library modules (csv, sys, random), so no additional packages are needed.

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/phil-grayson/SexFindR.git
cd SexFindR
```

### 2. Configure the Pipeline

Copy the configuration template and edit it:

```bash
cp config_template.sh config.sh
nano config.sh  # or use your preferred editor
```

Update the following paths in `config.sh`:
- `DIFCOVER_DIR`: Path to DifCover scripts directory
- `REFERENCE_GENOME`: Path to your reference genome FASTA file
- `BOWTIE2_INDEX`: Path to Bowtie2 index prefix
- Input/output directories
- Sample lists

### 3. Install DifCover

DifCover is required for Step 1. Download and install:

```bash
git clone https://github.com/genome/difcover.git
cd difcover
# Follow DifCover installation instructions
```

Update `DIFCOVER_DIR` in your `config.sh` file.

### 4. Prepare Your Data

Organize your data in the following structure:

```
SexFindR/
├── data/
│   ├── fastq/          # Input FASTQ files (for Step 0)
│   ├── bams/           # BAM files (output from Step 0 or input for Step 1)
│   └── vcfs/           # VCF files (for Step 2)
├── Step_0/
├── Step_1/
├── Step_2/
└── Step_3/
```

### 5. Create Sample Lists

Create text files listing your samples:

- `Step_0/male_samples.txt` - One sample ID per line
- `Step_0/female_samples.txt` - One sample ID per line

## Running the Pipeline

### Option 1: Run Individual Steps

#### Step 0: Mapping and Variant Calling

```bash
cd Step_0

# Create Bowtie2 index (if not already done)
bash bowtie2_makeindex_linux.sh <reference.fa> <index_prefix>

# Map reads for each sample
bash bowtie2_16_linux.sh <sample_R1.fq> <sample_R2.fq> <index_prefix>

# Variant calling (example with Platypus)
bash platypus_all_region_1day.sh <bam_file> <reference.fa>
```

#### Step 1: Coverage-based Analysis

```bash
cd Step_1

# Configure and run DifCover
# First, update run_difcover.sh with your DifCover path
bash run_difcover.sh <male_bam> <female_bam> <adjustment_coefficient>

# Run R analysis
Rscript Fugu_M98_F99_DifCover.R
```

#### Step 2: Sequence-based Analyses

```bash
cd Step_2

# Fst analysis
cd Fst
# Use VCFtools to calculate Fst
# Then run:
Rscript Fst_Results_Fugu.R

# GWAS analysis
cd ../GWAS
# Run GEMMA or PLINK for GWAS
# Process results as needed

# SNP Density
cd "../SNP Density"
bash SNPdensity.sh
Rscript SNPdensity_permutations_fugu.R

# k-mer GWAS
cd ../kmerGWAS
bash step1_kmerGWAS.sh
# Follow additional steps as needed
```

#### Step 3: Combined Analysis

```bash
cd Step_3

# Update file paths in Fugu_SexFindR.R to match your data
# Then run:
Rscript Fugu_SexFindR.R
```

### Option 2: Use the Main Pipeline Script

```bash
# Make the script executable
chmod +x run_pipeline.sh

# Run the pipeline
bash run_pipeline.sh
```

Note: The main script provides a framework but you may need to customize it for your specific data and workflow.

## Customization

### Modifying R Scripts

R scripts contain hardcoded paths (e.g., `~/SexFindR/Step_1/...`). Update these to match your directory structure:

```r
# Change from:
together <- read_tsv(file = "~/SexFindR/Step_1/...")

# To:
together <- read_tsv(file = "/path/to/your/SexFindR/Step_1/...")
```

### Adjusting Parameters

Key parameters can be adjusted in:
- `config.sh` - General pipeline parameters
- Individual script files - Step-specific parameters

## Troubleshooting

### Common Issues

1. **DifCover not found**: Ensure DifCover is installed and `DIFCOVER_DIR` in `config.sh` points to the correct location.

2. **R package errors**: Install missing packages using:
   ```r
   install.packages("package_name", repos="https://cran.rstudio.com/")
   ```

3. **Path errors in R scripts**: Update hardcoded paths in R scripts to match your system.

4. **Permission denied**: Make scripts executable:
   ```bash
   chmod +x *.sh
   ```

5. **Missing input files**: Ensure all required input files (BAMs, VCFs, etc.) are in the expected locations.

## Additional Resources

- **Documentation**: https://sexfindr.readthedocs.io/en/latest/
- **Publication**: https://www.biorxiv.org/content/10.1101/2022.02.21.481346v1
- **DifCover**: https://github.com/genome/difcover

## Support

For issues and questions:
- Check the documentation: https://sexfindr.readthedocs.io/
- Review the publication for methodology details
- Open an issue on GitHub: https://github.com/phil-grayson/SexFindR/issues

## License

Please refer to the original repository for license information.

