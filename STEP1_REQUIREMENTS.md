# Step 1 Requirements - Quick Guide

Since you've successfully loaded the Docker image and the pipeline runs, here's exactly what you need to run **Step 1: Coverage-based Analysis (DifCover)**.

## What You Need for Step 1

### 1. **BAM Files** (Required)
You need **at least 2 BAM files**:
- **1 male BAM file** - aligned to your reference genome
- **1 female BAM file** - aligned to the same reference genome

**Where to put them:**
- Place your BAM files in: `data/bams/`
- Example: `data/bams/male_sample.bam` and `data/bams/female_sample.bam`

**Note:** If you only have FASTQ files, you need to run **Step 0 first** to create BAM files from your FASTQ files.

### 2. **Adjustment Coefficient (AC)** (Required)
This accounts for differences in sequencing depth between your male and female samples.

**How to calculate AC:**
1. Calculate modal depth for each BAM file:
   ```bash
   # Inside Docker container or using Docker:
   docker run --rm -v "$(pwd)/data:/sexfindr/data" sexfindr:latest \
     bash -c "cd /sexfindr/data/bams && \
     for file in *.bam; do \
       samtools stats \$file > \${file}_temp && \
       number=\$(grep ^COV \${file}_temp | cut -f 2- | awk -v max=0 '{if(\$3>max){want=\$2; max=\$3}}END{print want}') && \
       echo \$file \$number > \${file}_modal_depth.txt && \
       rm \${file}_temp; \
     done"
   ```

2. Calculate AC:
   ```
   AC = (modal coverage of female sample) / (modal coverage of male sample)
   ```
   
   Example: If female modal depth = 50 and male modal depth = 45, then AC = 50/45 = 1.11

**Alternative:** If modal depth calculation doesn't work, you can use the ratio of BAM file sizes as a rough estimate, or start with AC = 1 (if you think coverage is similar).

### 3. **DifCover Scripts** (Already in Docker)
The Docker image should already have DifCover installed. The `run_difcover.sh` script will use the DifCover path configured in the Docker image.

## How to Run Step 1

### Option A: Run directly with Docker

```bash
# Make sure your BAM files are in data/bams/
# Replace MALE_BAM.bam and FEMALE_BAM.bam with your actual file names
# Replace 1.0 with your calculated AC value

docker run --rm \
  -v "$(pwd)/data:/sexfindr/data" \
  -v "$(pwd)/Step_1:/sexfindr/Step_1" \
  -v "$(pwd)/output:/sexfindr/output" \
  sexfindr:latest \
  bash -c "cd /sexfindr/Step_1 && \
    bash run_difcover.sh \
      /sexfindr/data/bams/MALE_BAM.bam \
      /sexfindr/data/bams/FEMALE_BAM.bam \
      1.0"
```

### Option B: Enter Docker container and run manually

```bash
# Enter the Docker container
docker run -it --rm \
  -v "$(pwd)/data:/sexfindr/data" \
  -v "$(pwd)/Step_1:/sexfindr/Step_1" \
  -v "$(pwd)/output:/sexfindr/output" \
  sexfindr:latest \
  /bin/bash

# Inside the container:
cd /sexfindr/Step_1
bash run_difcover.sh /sexfindr/data/bams/male_sample.bam /sexfindr/data/bams/female_sample.bam 1.0
```

### Option C: Run the R analysis after DifCover

After running DifCover, you can visualize results:

```bash
docker run --rm \
  -v "$(pwd)/Step_1:/sexfindr/Step_1" \
  -v "$(pwd)/output:/sexfindr/output" \
  sexfindr:latest \
  bash -c "cd /sexfindr/Step_1 && Rscript Fugu_M98_F99_DifCover.R"
```

**Note:** You may need to update the file paths in `Fugu_M98_F99_DifCover.R` to match your output file names.

## What Step 1 Does

Step 1 compares coverage between male and female samples to identify regions with sex-specific coverage differences. This helps identify potential sex chromosome regions.

## Expected Output

After running Step 1, you should see output files like:
- `sample1_sample2.unionbedcv`
- `sample1_sample2.ratio_per_w_CC0_a10_A219_b10_B240_v1000_l500`
- `sample1_sample2.ratio_per_w_CC0_a10_A219_b10_B240_v1000_l500.log2adj_1.DNAcopyout`
- Various histogram and fragment files

## Troubleshooting

1. **"DifCover not found" error:**
   - The Docker image should have DifCover. If not, check that the `FOLDER_PATH` in `run_difcover.sh` points to the correct location inside the container.

2. **"BAM file not found" error:**
   - Make sure your BAM files are in `data/bams/`
   - Use absolute paths or paths relative to the mounted volume

3. **"Permission denied" error:**
   - Make sure `run_difcover.sh` is executable:
     ```bash
     chmod +x Step_1/run_difcover.sh
     ```

4. **AC value issues:**
   - If results don't look right, try adjusting the AC value
   - The distribution should center around 0 for autosomes if AC is correct

## Next Steps

After Step 1 completes successfully:
- Review the output files
- Run the R visualization script
- Proceed to Step 2 if you have VCF files ready

