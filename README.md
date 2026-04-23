# SexFindR

This repository contains the basic scripts and configurations necessary to run a sex chromosome identification investigation as outlined in `SexFindR: A computational workflow to identify you and old sex chromsomes` (https://www.biorxiv.org/content/10.1101/2022.02.21.481346v1) alongside a detailed `Read the Docs` (https://sexfindr.readthedocs.io/en/latest/).

The folder structure in this repo mirrors the page structure in the `Read the Docs` to allow for ease of use.

## Quick Start

### 1. Install Dependencies

**Windows (PowerShell):**
```powershell
.\install_dependencies.ps1
```

**Linux/Mac (Bash):**
```bash
bash install_dependencies.sh
```

Or manually install R packages:
```r
install.packages(c('tidyverse', 'patchwork', 'ggpubr', 'ggthemes'), repos='https://cran.rstudio.com/')
```

### 2. Configure the Pipeline

Copy the configuration template and edit it:
```bash
cp config_template.sh config.sh
# Edit config.sh with your paths and settings
```

### 3. Run the Pipeline

See `SETUP.md` for detailed instructions on running each step of the pipeline.

## Pipeline Overview

The SexFindR pipeline consists of 4 main steps:

- **Step 0**: Mapping and variant calling (Bowtie2, SAMtools, variant callers)
- **Step 1**: Coverage-based analysis (DifCover)
- **Step 2**: Sequence-based analyses (Fst, GWAS, k-mer GWAS, SNP Density)
- **Step 3**: Combined sequence-based analysis

## Documentation

- **Detailed Setup Guide**: See [SETUP.md](SETUP.md)
- **Read the Docs**: https://sexfindr.readthedocs.io/en/latest/
- **Publication**: https://www.biorxiv.org/content/10.1101/2022.02.21.481346v1

## Requirements

- R (3.6+) with packages: tidyverse, patchwork, ggpubr, ggthemes
- Python 3.6+
- Bioinformatics tools: Bowtie2, SAMtools, VCFtools, PLINK, GEMMA
- DifCover: https://github.com/genome/difcover

## Files Added for Pipeline Setup

- `requirements_R.txt` - R package dependencies
- `config_template.sh` - Configuration template
- `run_pipeline.sh` - Main pipeline orchestration script
- `install_dependencies.sh` - Bash script to install R packages
- `install_dependencies.ps1` - PowerShell script to install R packages (Windows)
- `SETUP.md` - Comprehensive setup and usage guide