# BAM Files for Step 1 - Complete Guide

## ❗ Important: You Need **2 BAM Files**, Not Just One!

Step 1 compares coverage between **one male** and **one female** sample. You need **both** files.

## What Type of BAM Files Do You Need?

### Required: 2 BAM Files
1. **1 Male BAM file** - Sequencing data from a male individual
2. **1 Female BAM file** - Sequencing data from a female individual

### BAM File Requirements:

✅ **Must be aligned** to the same reference genome  
✅ **Should be sorted** (coordinate-sorted)  
✅ **Should be indexed** (have a `.bai` index file)  
✅ **Same reference genome** for both files  

## Example BAM Files

### Example 1: Simple Naming
```
data/bams/
├── male_sample.bam          ← Male BAM file
├── male_sample.bam.bai      ← Index file (optional but recommended)
├── female_sample.bam        ← Female BAM file
└── female_sample.bam.bai    ← Index file (optional but recommended)
```

### Example 2: With Sample IDs
```
data/bams/
├── SRR8585998.bam           ← Male sample (from SRA)
├── SRR8585998.bam.bai
├── SRR8585999.bam           ← Female sample (from SRA)
└── SRR8585999.bam.bai
```

### Example 3: Descriptive Names
```
data/bams/
├── individual_M001.bam      ← Male individual
├── individual_M001.bam.bai
├── individual_F001.bam      ← Female individual
└── individual_F001.bam.bai
```

## What Makes a Good BAM File?

### ✅ Good BAM File Characteristics:
- **Aligned reads**: Reads are mapped to a reference genome
- **Sorted**: Coordinate-sorted (not name-sorted)
- **Indexed**: Has a `.bai` index file for fast access
- **Good coverage**: Typically 10-50x coverage or more
- **Quality**: Reads are properly aligned (not too many unmapped reads)

### ❌ Bad BAM Files:
- Unaligned reads (just raw sequencing data)
- Name-sorted instead of coordinate-sorted
- Different reference genomes for male vs female
- Very low coverage (< 5x)
- Corrupted or incomplete files

## How to Check Your BAM Files

### Check if BAM file is sorted and indexed:
```bash
# Using samtools (inside Docker)
docker run --rm -v "$(pwd)/data:/sexfindr/data" sexfindr:latest \
  bash -c "cd /sexfindr/data/bams && \
    samtools view -H your_file.bam | grep '^@HD'"
```

### Check BAM file statistics:
```bash
docker run --rm -v "$(pwd)/data:/sexfindr/data" sexfindr:latest \
  bash -c "cd /sexfindr/data/bams && \
    samtools stats your_file.bam | head -20"
```

## Where Do BAM Files Come From?

### Option 1: You Already Have BAM Files
- If you have BAM files from a previous analysis
- Make sure they're aligned to the same reference genome
- Put them in `data/bams/`

### Option 2: Create from FASTQ Files (Step 0)
- If you have FASTQ files, run Step 0 first
- Step 0 will create BAM files from your FASTQ files
- Then use those BAM files for Step 1

### Option 3: Download from Public Databases
- SRA (Sequence Read Archive)
- ENA (European Nucleotide Archive)
- Download FASTQ files, then align them (Step 0)

## Minimum Requirements for Step 1

**You need:**
- ✅ **2 BAM files** (1 male + 1 female)
- ✅ Both aligned to the **same reference genome**
- ✅ Files are **coordinate-sorted**
- ✅ Files are in the `data/bams/` folder

**You don't need:**
- ❌ Multiple male or female samples (1 of each is enough)
- ❌ Index files (`.bai`) - helpful but not required
- ❌ VCF files (those are for Step 2)

## Example: Real-World Scenario

Let's say you're studying a fish species:

1. **You have:**
   - `male_fish_001.bam` - BAM file from male fish
   - `female_fish_001.bam` - BAM file from female fish

2. **Both files:**
   - Aligned to the same reference genome (e.g., `Takifugu_rubripes.fa`)
   - Sorted by coordinate
   - Have good coverage (20-30x)

3. **Put them in:**
   ```
   data/bams/
   ├── male_fish_001.bam
   └── female_fish_001.bam
   ```

4. **Run Step 1:**
   ```bash
   bash run_difcover.sh male_fish_001.bam female_fish_001.bam 1.0
   ```

## Using the Web Interface

If you're using the web interface:

1. **Select "BAM Files"** as your data type
2. **Upload both files:**
   - Upload `male_sample.bam`
   - Upload `female_sample.bam`
3. **Set Adjustment Coefficient** (start with 1.0)
4. **Click "Start Pipeline"**

The interface will automatically detect both files and use them for comparison.

## Troubleshooting

### "Need at least 2 BAM files"
- Make sure you uploaded **both** a male and female BAM file
- Check that files are in `data/bams/` folder
- Verify file extensions are `.bam`

### "BAM files not aligned to same reference"
- Both files must use the same reference genome
- Check the `@SQ` headers in the BAM files
- Re-align if they use different references

### "BAM file is not sorted"
- Sort the BAM file: `samtools sort input.bam -o sorted.bam`
- Then index: `samtools index sorted.bam`

## Summary

**For Step 1, you need:**
- ✅ **2 BAM files** (1 male + 1 female)
- ✅ Same reference genome
- ✅ Coordinate-sorted
- ✅ In `data/bams/` folder

**That's it!** Step 1 will compare coverage between these two files to identify sex-specific regions.




