# Step 0 Not Yet Implemented in Web Interface

## Why Step 0 Failed

Step 0 (FASTQ to BAM mapping) requires several additional components that are not yet fully integrated into the web interface:

1. **Reference Genome** - Needs to be mounted/accessible
2. **Bowtie2 Index** - Pre-built index files
3. **Sample Lists** - male_samples.txt and female_samples.txt
4. **Complex Scripts** - Multiple mapping scripts

## Solutions

### Option 1: Use BAM Files Directly (Recommended) ✅

**Instead of FASTQ files, use BAM files:**

1. If you have FASTQ files, convert them to BAM files first using command line
2. Then upload the BAM files to the web interface
3. Run Step 1 directly with BAM files

**This is the easiest approach!**

### Option 2: Run Step 0 Manually

If you need to run Step 0, use the command line scripts:

```bash
# On Windows
cd Step_0
powershell -ExecutionPolicy Bypass -File run_step0_mapping.ps1

# On Mac/Linux
cd Step_0
bash run_step0_mapping.sh
```

Then upload the resulting BAM files to the web interface.

### Option 3: Use Docker Directly

```bash
docker run --rm \
  -v "$(pwd)/data:/sexfindr/data" \
  -v "$(pwd)/Step_0:/sexfindr/Step_0" \
  -v "$(pwd)/config.sh:/sexfindr/config.sh" \
  sexfindr:latest \
  bash -c "cd /sexfindr/Step_0 && bash run_step0_mapping.sh"
```

## What Works in Web Interface

✅ **Step 1 (BAM files)** - Fully working  
✅ **File upload** - Works for BAM, FASTQ, VCF  
✅ **Step 1 DifCover analysis** - Complete  
❌ **Step 0 (FASTQ mapping)** - Not yet implemented  
❌ **Step 2 (VCF analysis)** - Not yet implemented  

## Recommendation

**For now, use BAM files directly:**
1. Convert FASTQ to BAM using command line (if needed)
2. Upload BAM files to web interface
3. Run Step 1

This is the most reliable approach until Step 0 is fully integrated.




