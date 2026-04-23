# Data Organization Guide - SexFindR Pipeline

## Step-by-Step Instructions

### Step 1: Identify Your Data Type

You need to determine what type of sequencing data you have:

#### Option A: FASTQ Files (Raw Sequencing Reads)
- **File extensions**: `.fastq`, `.fq`, `.fastq.gz`, `.fq.gz`
- **What they are**: Raw sequencing data from the sequencer
- **Naming**: Usually `sample_R1.fastq` and `sample_R2.fastq` for paired-end
- **Action**: Copy to `data/fastq/`
- **Start with**: Step 0 (Mapping and variant calling)

#### Option B: BAM Files (Aligned Reads)
- **File extension**: `.bam`
- **What they are**: Reads aligned to a reference genome
- **Naming**: Usually `sample.bam`
- **Action**: Copy to `data/bams/`
- **Start with**: Step 1 (Coverage-based analysis with DifCover)

#### Option C: VCF Files (Variant Calls)
- **File extensions**: `.vcf`, `.vcf.gz`
- **What they are**: Variant call files with SNPs/indels
- **Naming**: Usually `sample.vcf` or `all_samples.vcf`
- **Action**: Copy to `data/vcfs/`
- **Start with**: Step 2 (Sequence-based analyses)

### Step 2: Organize Your Files

#### For FASTQ Files:
1. Copy your FASTQ files to: `C:\Users\msi\SexFindR\data\fastq\`
2. Ensure naming follows pattern: `sample_name_R1.fastq` and `sample_name_R2.fastq`
3. Example:
   ```
   data/fastq/
   ├── male_001_R1.fastq
   ├── male_001_R2.fastq
   ├── male_002_R1.fastq
   ├── male_002_R2.fastq
   ├── female_001_R1.fastq
   ├── female_001_R2.fastq
   └── ...
   ```

#### For BAM Files:
1. Copy your BAM files to: `C:\Users\msi\SexFindR\data\bams\`
2. Ensure files are sorted and indexed (if not, use `samtools sort` and `samtools index`)
3. Example:
   ```
   data/bams/
   ├── male_001.bam
   ├── male_001.bam.bai
   ├── male_002.bam
   ├── male_002.bam.bai
   ├── female_001.bam
   ├── female_001.bam.bai
   └── ...
   ```

#### For VCF Files:
1. Copy your VCF files to: `C:\Users\msi\SexFindR\data\vcfs\`
2. Example:
   ```
   data/vcfs/
   ├── all_samples.vcf
   └── ...
   ```

### Step 3: Create Sample Lists

Edit the sample list files with your actual sample IDs:

#### Edit `Step_0/male_samples.txt`:
```
male_001
male_002
male_003
```
(One sample ID per line, no file extensions, no paths)

#### Edit `Step_0/female_samples.txt`:
```
female_001
female_002
female_003
```
(One sample ID per line, no file extensions, no paths)

**Important**: The sample IDs in these files must match the file names (without extensions).

### Step 4: Verify Your Setup

Check that:
- ✅ Data files are in the correct directory
- ✅ Sample IDs in list files match file names
- ✅ File naming is consistent
- ✅ BAM files are sorted and indexed (if using BAM files)

### Step 5: Run the Pipeline

Based on your data type, start with the appropriate step:

#### If you have FASTQ files:
```bash
cd Step_0
# Follow instructions in SETUP.md for Step 0
```

#### If you have BAM files:
```bash
cd Step_1
# Run DifCover analysis
bash run_difcover.sh <male_bam> <female_bam> <adjustment_coefficient>
```

#### If you have VCF files:
```bash
cd Step_2
# Run sequence-based analyses
# See SETUP.md for detailed instructions
```

## Quick Reference

| Data Type | Directory | Sample List Format | Starting Step |
|-----------|-----------|-------------------|---------------|
| FASTQ | `data/fastq/` | `sample_name` | Step 0 |
| BAM | `data/bams/` | `sample_name` | Step 1 |
| VCF | `data/vcfs/` | `sample_name` | Step 2 |

## Need Help?

- Check `SETUP.md` for detailed pipeline instructions
- Check `QUICK_START.md` for quick reference
- Review the documentation: https://sexfindr.readthedocs.io/

