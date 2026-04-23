# Configuration Guide for SexFindR

This guide will help you configure `config.sh` for your SexFindR pipeline.

## Step 1: Copy the Template

First, copy the template file to create your configuration file:

**On Windows (PowerShell):**
```powershell
Copy-Item config_template.sh config.sh
```

**On Linux/Mac or Git Bash:**
```bash
cp config_template.sh config.sh
```

## Step 2: Edit config.sh

Open `config.sh` in a text editor and update the following sections:

### Required Paths (MUST be configured)

#### 1. DifCover Directory
```bash
DIFCOVER_DIR="/path/to/difcover/scripts"
```
**What to do:**
- Download DifCover from: https://github.com/genome/difcover
- Clone or download it to a location on your system
- Point to the `scripts` directory inside DifCover

**Example (Windows with Git Bash/WSL):**
```bash
DIFCOVER_DIR="/c/Users/msi/difcover/scripts"
# or
DIFCOVER_DIR="/home/msi/difcover/scripts"  # if using WSL
```

**Example (Linux/Mac):**
```bash
DIFCOVER_DIR="/home/username/difcover/scripts"
```

#### 2. Reference Genome
```bash
REFERENCE_GENOME="/path/to/reference/genome.fa"
```
**What to do:**
- Provide the full path to your reference genome FASTA file
- This is the genome assembly you'll use for mapping

**Example:**
```bash
REFERENCE_GENOME="/c/Users/msi/data/reference/genome.fa"
```

#### 3. Bowtie2 Index
```bash
BOWTIE2_INDEX="/path/to/bowtie2/index/prefix"
```
**What to do:**
- This is the prefix of your Bowtie2 index files (without the `.bt2` extension)
- If you haven't created the index yet, you'll need to run:
  ```bash
  bowtie2-build reference.fa index_prefix
  ```
- Then point to that prefix

**Example:**
```bash
BOWTIE2_INDEX="/c/Users/msi/data/bowtie2_index/genome"
# This would reference files like:
# genome.1.bt2, genome.2.bt2, genome.3.bt2, etc.
```

### Optional Paths (usually work with defaults)

These paths use `${SEXFINDR_DIR}` which automatically points to your SexFindR directory. You can leave them as-is, or customize:

```bash
# Input data directories (relative to SexFindR directory)
BAM_DIR="${SEXFINDR_DIR}/data/bams"      # Where your BAM files are
VCF_DIR="${SEXFINDR_DIR}/data/vcfs"      # Where your VCF files are
FASTQ_DIR="${SEXFINDR_DIR}/data/fastq"   # Where your FASTQ files are

# Output directory
OUTPUT_DIR="${SEXFINDR_DIR}/output"      # Where results will be saved

# Sample lists
MALE_SAMPLES="${SEXFINDR_DIR}/Step_0/male_samples.txt"
FEMALE_SAMPLES="${SEXFINDR_DIR}/Step_0/female_samples.txt"
```

**Note:** You'll need to create the sample list files:
- `Step_0/male_samples.txt` - One sample ID per line
- `Step_0/female_samples.txt` - One sample ID per line

### Computational Resources

Adjust these based on your computer:

```bash
THREADS=16        # Number of CPU cores to use (adjust to your system)
MEMORY="32G"      # Amount of RAM available (adjust to your system)
```

**For a typical laptop:**
```bash
THREADS=4         # or 8 if you have 8 cores
MEMORY="16G"      # or "8G" if you have less RAM
```

### Analysis Parameters

These are usually fine as defaults, but you can adjust based on your data:

#### Step 1 - DifCover Parameters
```bash
MIN_COV_SAMPLE1=10      # Minimum coverage for sample 1
MAX_COV_SAMPLE1=219     # Maximum coverage for sample 1
MIN_COV_SAMPLE2=10      # Minimum coverage for sample 2
MAX_COV_SAMPLE2=240     # Maximum coverage for sample 2
TARGET_VALID_BASES=1000 # Target number of valid bases
MIN_WINDOW_SIZE=500     # Minimum window size
ADJUSTMENT_COEFFICIENT=1 # Adjustment coefficient
ENRICHMENT_THRESHOLD=0.7369656 # Enrichment threshold
```

#### Step 2 - Analysis Parameters
```bash
WINDOW_SIZE=10000       # Window size for analysis (in base pairs)
FST_THRESHOLD=0.05      # Fst threshold for significance
GWAS_TOP_PERCENT=5      # Top percentage for GWAS results
```

#### Step 3 - Combined Analysis
```bash
SNP_DENSITY_TOP_RANK=100  # Top N regions by SNP density
GWAS_TOP_RANK=100         # Top N regions by GWAS
FST_TOP_RANK=100          # Top N regions by Fst
```

## Step 3: Verify Your Configuration

After editing, check that:
1. All paths use forward slashes `/` (even on Windows if using Git Bash/WSL)
2. Paths don't have trailing slashes (except for directories if needed)
3. File paths point to actual files that exist (or will exist)
4. Directory paths point to directories that exist (or will be created)

## Example Complete Configuration

Here's an example of what a configured `config.sh` might look like:

```bash
#!/bin/bash
# Configuration for SexFindR pipeline

# Base directory for SexFindR
SEXFINDR_DIR="${PWD}"

# DifCover scripts directory
DIFCOVER_DIR="/c/Users/msi/tools/difcover/scripts"

# Reference genome path
REFERENCE_GENOME="/c/Users/msi/data/genomes/my_genome.fa"

# Bowtie2 index prefix
BOWTIE2_INDEX="/c/Users/msi/data/bowtie2_index/my_genome"

# Input data directories
BAM_DIR="${SEXFINDR_DIR}/data/bams"
VCF_DIR="${SEXFINDR_DIR}/data/vcfs"
FASTQ_DIR="${SEXFINDR_DIR}/data/fastq"

# Output directory
OUTPUT_DIR="${SEXFINDR_DIR}/output"

# Sample lists
MALE_SAMPLES="${SEXFINDR_DIR}/Step_0/male_samples.txt"
FEMALE_SAMPLES="${SEXFINDR_DIR}/Step_0/female_samples.txt"

# Computational resources
THREADS=8
MEMORY="16G"

# Step 1 - DifCover parameters (using defaults)
MIN_COV_SAMPLE1=10
MAX_COV_SAMPLE1=219
MIN_COV_SAMPLE2=10
MAX_COV_SAMPLE2=240
TARGET_VALID_BASES=1000
MIN_WINDOW_SIZE=500
ADJUSTMENT_COEFFICIENT=1
ENRICHMENT_THRESHOLD=0.7369656

# Step 2 - Analysis parameters (using defaults)
WINDOW_SIZE=10000
FST_THRESHOLD=0.05
GWAS_TOP_PERCENT=5

# Step 3 - Combined analysis parameters (using defaults)
SNP_DENSITY_TOP_RANK=100
GWAS_TOP_RANK=100
FST_TOP_RANK=100
```

## Windows-Specific Notes

If you're using **Git Bash** or **WSL** on Windows:
- Use forward slashes `/` in paths
- Windows paths like `C:\Users\msi\...` become `/c/Users/msi/...` in Git Bash
- Or use WSL paths like `/mnt/c/Users/msi/...`

If you're using **PowerShell** or **Command Prompt**:
- The bash scripts may not work directly
- Consider using WSL or Git Bash for running the pipeline
- Or adapt the scripts for Windows (they're bash scripts, so WSL/Git Bash is recommended)

## Next Steps

After configuring `config.sh`:
1. Create your sample list files (`male_samples.txt` and `female_samples.txt`)
2. Organize your data in the `data/` directory structure
3. Install DifCover if you haven't already
4. Create Bowtie2 index if you haven't already
5. Run the pipeline steps as described in `SETUP.md`

## Need Help?

- Check `SETUP.md` for detailed setup instructions
- Review the documentation: https://sexfindr.readthedocs.io/
- See the publication for methodology details


