# Data Organization Guide - When You Only Have the Scripts

If the professor only gave you `run_pipeline.sh` and `run_all_steps.sh`, here's exactly how to organize your data to make them work.

## Step 1: Create the Required Folder Structure

Create a project folder and set up the exact structure the scripts expect:

```bash
# Create a project folder (choose any location)
mkdir -p ~/Desktop/SexFindR_Project
cd ~/Desktop/SexFindR_Project

# Create the required folder structure
mkdir -p data/fastq      # For FASTQ files (if you have them)
mkdir -p data/bams       # For BAM files (needed for Step 1)
mkdir -p data/vcfs       # For VCF files (if you have them)
mkdir -p Step_0          # For Step 0 outputs
mkdir -p Step_1          # For Step 1 outputs
mkdir -p Step_2          # For Step 2 outputs
mkdir -p Step_3          # For Step 3 outputs
mkdir -p output          # For final results
```

## Step 2: Copy the Scripts

Put the scripts in your project folder:

```bash
# Copy the scripts to your project folder
cp /path/to/run_pipeline.sh ~/Desktop/SexFindR_Project/
cp /path/to/run_all_steps.sh ~/Desktop/SexFindR_Project/

# Make them executable
chmod +x ~/Desktop/SexFindR_Project/run_pipeline.sh
chmod +x ~/Desktop/SexFindR_Project/run_all_steps.sh
```

## Step 3: Put Your Data Files

### For Step 1 (BAM files - Most Common):

**Put your BAM files in: `data/bams/`**

```bash
# Copy your BAM files
cp /path/to/your/male_sample.bam ~/Desktop/SexFindR_Project/data/bams/
cp /path/to/your/female_sample.bam ~/Desktop/SexFindR_Project/data/bams/

# Verify they're there
ls -lh ~/Desktop/SexFindR_Project/data/bams/
```

**You need:**
- At least 1 male BAM file
- At least 1 female BAM file

### For Step 0 (FASTQ files):

**Put your FASTQ files in: `data/fastq/`**

```bash
# Copy your FASTQ files
cp /path/to/your/*.fastq ~/Desktop/SexFindR_Project/data/fastq/
# or
cp /path/to/your/*.fq ~/Desktop/SexFindR_Project/data/fastq/
```

### For Step 2 (VCF files):

**Put your VCF files in: `data/vcfs/`**

```bash
# Copy your VCF files
cp /path/to/your/*.vcf ~/Desktop/SexFindR_Project/data/vcfs/
```

## Step 4: Create Sample Lists (For run_all_steps.sh)

If using `run_all_steps.sh`, create sample list files:

```bash
cd ~/Desktop/SexFindR_Project

# Create male samples list
cat > Step_0/male_samples.txt << EOF
male_sample_1
male_sample_2
EOF

# Create female samples list
cat > Step_0/female_samples.txt << EOF
female_sample_1
female_sample_2
EOF
```

**Important:** The sample IDs should match your file names (without extensions).

For example:
- If your BAM file is `male_001.bam`, the sample ID should be `male_001`
- If your FASTQ file is `female_002_R1.fastq`, the sample ID should be `female_002`

## Step 5: Create config.sh (For run_all_steps.sh)

If using `run_all_steps.sh`, you need a `config.sh` file. Create a minimal one:

```bash
cd ~/Desktop/SexFindR_Project

cat > config.sh << 'EOF'
#!/bin/bash
# Minimal config for SexFindR

# Base directory
SEXFINDR_DIR="${PWD}"

# Adjustment Coefficient for Step 1 (start with 1.0)
ADJUSTMENT_COEFFICIENT=1.0

# Reference genome (if needed)
# REFERENCE_GENOME="/path/to/reference.fa"

# Bowtie2 index (if needed)
# BOWTIE2_INDEX="/path/to/index"
EOF

chmod +x config.sh
```

## Step 6: Final Folder Structure

Your project should look like this:

```
SexFindR_Project/
│
├── run_pipeline.sh          ← The script you received
├── run_all_steps.sh          ← The script you received
├── config.sh                 ← Create this (for run_all_steps.sh)
│
├── data/
│   ├── fastq/                ← Put FASTQ files here (optional)
│   ├── bams/                 ← PUT YOUR BAM FILES HERE
│   │   ├── male_sample.bam
│   │   └── female_sample.bam
│   └── vcfs/                 ← Put VCF files here (optional)
│
├── Step_0/
│   ├── male_samples.txt      ← Create this (for run_all_steps.sh)
│   └── female_samples.txt    ← Create this (for run_all_steps.sh)
│
├── Step_1/                   ← Created automatically
├── Step_2/                   ← Created automatically
├── Step_3/                   ← Created automatically
└── output/                   ← Results go here
```

## Step 7: Run the Scripts

### Option A: Using run_pipeline.sh (Simpler)

```bash
cd ~/Desktop/SexFindR_Project
./run_pipeline.sh
```

This script will:
- Detect what type of data you have (FASTQ, BAM, or VCF)
- Run the appropriate step automatically
- Save results to `output/`

**Note:** For BAM files, `run_pipeline.sh` will detect them but may need manual configuration for Step 1.

### Option B: Using run_all_steps.sh (More Complete)

```bash
cd ~/Desktop/SexFindR_Project
./run_all_steps.sh
```

This script will:
- Run all applicable steps
- Use parallel execution for Step 2
- Create completion markers
- Save all results to `output/`

## Quick Reference

| What You Have | Where to Put It | Script to Use |
|---------------|-----------------|---------------|
| BAM files | `data/bams/` | `run_pipeline.sh` or `run_all_steps.sh` |
| FASTQ files | `data/fastq/` | `run_all_steps.sh` (needs config.sh) |
| VCF files | `data/vcfs/` | `run_all_steps.sh` (needs config.sh) |

## Minimal Setup for Step 1 (BAM files)

If you only have BAM files and want to run Step 1:

```bash
# 1. Create folders
mkdir -p ~/Desktop/MyAnalysis/data/bams
mkdir -p ~/Desktop/MyAnalysis/Step_1
mkdir -p ~/Desktop/MyAnalysis/output

# 2. Copy scripts
cp run_pipeline.sh ~/Desktop/MyAnalysis/
cp run_all_steps.sh ~/Desktop/MyAnalysis/
chmod +x ~/Desktop/MyAnalysis/*.sh

# 3. Put BAM files
cp /path/to/male.bam ~/Desktop/MyAnalysis/data/bams/
cp /path/to/female.bam ~/Desktop/MyAnalysis/data/bams/

# 4. Create minimal config (for run_all_steps.sh)
cat > ~/Desktop/MyAnalysis/config.sh << 'EOF'
#!/bin/bash
ADJUSTMENT_COEFFICIENT=1.0
EOF

# 5. Create sample lists (for run_all_steps.sh)
mkdir -p ~/Desktop/MyAnalysis/Step_0
echo "male" > ~/Desktop/MyAnalysis/Step_0/male_samples.txt
echo "female" > ~/Desktop/MyAnalysis/Step_0/female_samples.txt

# 6. Run
cd ~/Desktop/MyAnalysis
./run_all_steps.sh
```

## Troubleshooting

**"No data files found"**
- Make sure files are in the correct `data/` subfolder
- Check file extensions match (.bam, .fastq, .vcf)
- Use: `ls -lh data/bams/` to verify

**"config.sh not found"**
- Only needed for `run_all_steps.sh`
- Create a minimal `config.sh` as shown above

**"Docker image not found"**
- Load the Docker image first: `docker load -i sexfindr_image.tar`
- Check: `docker images | grep sexfindr`

**"Permission denied"**
- Make scripts executable: `chmod +x *.sh`

## Summary

**Minimum needed for Step 1:**
1. ✅ Folder: `data/bams/`
2. ✅ Your BAM files in that folder
3. ✅ Scripts: `run_pipeline.sh` or `run_all_steps.sh`
4. ✅ Docker image loaded
5. ✅ (Optional) `config.sh` and sample lists for `run_all_steps.sh`

That's it! The scripts will handle the rest.




