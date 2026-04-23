# Master Pipeline Script - Run All Steps

## Overview

The `run_all_steps.sh` script runs the entire SexFindR pipeline from start to finish, with **parallel execution** where possible. It works on both **Windows** (Git Bash/WSL) and **macOS/Linux**.

## Features

✅ **Runs all 4 steps automatically**  
✅ **Parallel execution** of independent tasks  
✅ **Dependency management** - waits for required steps  
✅ **Progress tracking** with logs  
✅ **Skip completed steps** (unless forced)  
✅ **Cross-platform** (Windows/macOS/Linux)  
✅ **Docker-based** execution  

## How It Works

### Execution Flow

```
Step 0: Mapping (if FASTQ files exist)
    ↓
    ├─→ Step 1: DifCover (coverage analysis)
    │
    └─→ Step 2: Sequence analyses (runs in parallel)
            ├─→ Fst Analysis ─┐
            ├─→ GWAS ─────────┤ All run
            ├─→ k-mer GWAS ───┤ in parallel
            └─→ SNP Density ───┘
                ↓
Step 3: Combined Analysis (waits for Step 1 & 2)
```

### Parallel Execution

- **Step 2 analyses** run in parallel (Fst, GWAS, k-mer GWAS, SNP Density)
- **Multiple samples** in Step 0 can be processed in parallel (if implemented)
- Each parallel task has its own log file

## Usage

### Basic Usage

```bash
# Make script executable (first time only)
chmod +x run_all_steps.sh

# Run the entire pipeline
./run_all_steps.sh
```

### Force Rerun

To rerun all steps even if outputs exist:

```bash
FORCE_RERUN=true ./run_all_steps.sh
```

### Windows (Git Bash)

```bash
# In Git Bash
cd /c/Users/msi/SexFindR
chmod +x run_all_steps.sh
./run_all_steps.sh
```

### Windows (WSL)

```bash
# In WSL
cd /mnt/c/Users/msi/SexFindR
chmod +x run_all_steps.sh
./run_all_steps.sh
```

### macOS/Linux

```bash
chmod +x run_all_steps.sh
./run_all_steps.sh
```

## Prerequisites

1. **Docker Desktop** installed and running
2. **Docker image loaded**: Run `./load_docker.sh` first
3. **Data files** in appropriate directories:
   - FASTQ files → `data/fastq/`
   - BAM files → `data/bams/`
   - VCF files → `data/vcfs/`
4. **Sample lists** (for Step 0):
   - `Step_0/male_samples.txt`
   - `Step_0/female_samples.txt`
5. **config.sh** configured

## What Gets Executed

### Step 0: Mapping (if FASTQ files found)
- Maps FASTQ files to reference genome
- Creates BAM files
- Creates Bowtie2 index if needed
- **Output**: BAM files in `data/bams/`

### Step 1: DifCover (if BAM files found)
- Compares coverage between male and female BAM files
- Identifies regions with different coverage
- **Output**: Coverage analysis files in `output/Step_1/`

### Step 2: Sequence Analyses (if VCF files found)
Runs **4 analyses in parallel**:

1. **Fst Analysis**: Genetic differentiation between sexes
2. **GWAS**: Genome-wide association with sex
3. **k-mer GWAS**: Sex-linked sequence analysis
4. **SNP Density**: Variant density patterns

**Output**: Results in `output/Step_2/` subdirectories

### Step 3: Combined Analysis
- Combines results from Step 1 and Step 2
- Creates final sex chromosome identification
- **Output**: Combined results in `output/Step_3/`

## Output Structure

```
output/
├── Step_0/
│   └── step0_complete.txt
├── Step_1/
│   ├── difcover_complete.txt
│   └── *.DNAcopyout files
├── Step_2/
│   ├── Fst/
│   │   └── fst_complete.txt
│   ├── GWAS/
│   │   └── gwas_complete.txt
│   ├── kmerGWAS/
│   │   └── kmers_complete.txt
│   └── SNP_Density/
│       └── snpdensity_complete.txt
├── Step_3/
│   └── combined_complete.txt
└── logs/
    ├── step2_fst.log
    ├── step2_gwas.log
    ├── step2_kmers.log
    └── step2_snpdensity.log
```

## Logs

All parallel tasks write logs to `output/logs/`:
- `step2_fst.log` - Fst analysis log
- `step2_gwas.log` - GWAS analysis log
- `step2_kmers.log` - k-mer GWAS log
- `step2_snpdensity.log` - SNP density log

Check logs if any step fails.

## Customization

### Skip Specific Steps

Edit the script and comment out sections you don't want to run.

### Adjust Parallel Jobs

The script automatically runs Step 2 analyses in parallel. To limit parallelism, modify the `run_parallel` function.

### Change Docker Resources

Add resource limits to Docker commands:
```bash
docker run --rm --cpus="4" --memory="8g" ...
```

## Troubleshooting

### "Docker is not running"
- Open Docker Desktop
- Wait until it shows "Docker is running"

### "Docker image not found"
- Run `./load_docker.sh` first

### "Step X failed"
- Check the log file in `output/logs/`
- Verify input data is correct
- Check `config.sh` settings

### "No data files found"
- Ensure files are in correct directories:
  - FASTQ → `data/fastq/`
  - BAM → `data/bams/`
  - VCF → `data/vcfs/`

### Step 2 analyses not running in parallel
- Check if you have VCF files
- Verify Docker has enough resources
- Check logs for errors

## Performance Tips

1. **Use SSD** for data directory (faster I/O)
2. **Allocate enough Docker resources** (CPU/memory)
3. **Run on a machine with multiple cores** (better parallelization)
4. **Monitor Docker resources** during execution

## Example Run

```bash
$ ./run_all_steps.sh

========================================
SexFindR Master Pipeline - All Steps
========================================

Checking Docker...
Docker OK

========================================
STEP 0: Mapping and Variant Calling
========================================

Mapping FASTQ files to reference genome...
Step 0 completed!

========================================
STEP 1: Coverage-based Analysis (DifCover)
========================================

Running DifCover analysis...
Step 1 completed!

========================================
STEP 2: Sequence-based Analyses (Running in Parallel)
========================================

Starting Fst analysis (background)...
Starting GWAS analysis (background)...
Starting k-mer GWAS analysis (background)...
Starting SNP Density analysis (background)...
Waiting for all jobs to complete...
✓ Completed: step2_fst
✓ Completed: step2_gwas
✓ Completed: step2_kmers
✓ Completed: step2_snpdensity
All jobs completed!
Step 2 analyses completed!

========================================
STEP 3: Combined Analysis
========================================

Combining results from all steps...
Step 3 completed!

========================================
Pipeline Complete!
========================================

All steps completed successfully!
```

## Notes

- The script uses Docker for all execution (consistent environment)
- Steps are skipped if output already exists (unless `FORCE_RERUN=true`)
- Parallel execution only works for independent tasks
- Step 3 waits for Step 1 and Step 2 to complete

## Next Steps

After the pipeline completes:
1. Check results in `output/` directory
2. Review logs in `output/logs/` for any warnings
3. Visualize results using R scripts in Step_3
4. Interpret findings based on your species

---

**Questions?** Check `TROUBLESHOOTING.md` or the main documentation.

