# Folder Structure Needed for run_pipeline.sh and run_all_steps.sh

## Required Folder Structure

```
YourProjectFolder/
│
├── run_pipeline.sh          ← Script you received
├── run_all_steps.sh         ← Script you received
├── config.sh                ← CREATE THIS (see below)
│
├── data/
│   ├── fastq/               ← Put FASTQ files here (optional)
│   ├── bams/                ← ⭐ PUT YOUR BAM FILES HERE
│   └── vcfs/                ← Put VCF files here (optional)
│
├── Step_0/
│   ├── male_samples.txt      ← CREATE THIS (for run_all_steps.sh)
│   └── female_samples.txt   ← CREATE THIS (for run_all_steps.sh)
│
├── Step_1/                  ← Created automatically
├── Step_2/                  ← Created automatically
├── Step_3/                  ← Created automatically
└── output/                  ← Results go here
```

## Quick Setup Commands

```bash
# 1. Create all folders
mkdir -p data/{fastq,bams,vcfs} Step_{0,1,2,3} output

# 2. Put your BAM files
cp /path/to/your/*.bam data/bams/

# 3. Create config.sh
cat > config.sh << 'EOF'
#!/bin/bash
ADJUSTMENT_COEFFICIENT=1.0
EOF
chmod +x config.sh

# 4. Create sample lists (for run_all_steps.sh)
echo "male_sample" > Step_0/male_samples.txt
echo "female_sample" > Step_0/female_samples.txt

# 5. Make scripts executable
chmod +x run_pipeline.sh run_all_steps.sh

# 6. Run!
./run_all_steps.sh
```

## What Goes Where

| Your Data | Put It Here | Required? |
|-----------|-------------|-----------|
| BAM files | `data/bams/` | ✅ Yes (for Step 1) |
| FASTQ files | `data/fastq/` | Optional |
| VCF files | `data/vcfs/` | Optional |
| Scripts | Root folder | ✅ Yes |
| config.sh | Root folder | ✅ Yes (for run_all_steps.sh) |
| Sample lists | `Step_0/` | ✅ Yes (for run_all_steps.sh) |

## Minimal Setup (Just for Step 1)

If you only want to run Step 1 with BAM files:

```bash
# Minimum folders needed
mkdir -p data/bams Step_1 output

# Put BAM files
cp your_male.bam data/bams/
cp your_female.bam data/bams/

# Create minimal config
echo 'ADJUSTMENT_COEFFICIENT=1.0' > config.sh

# Run
./run_all_steps.sh
```

That's it! The scripts will create other folders as needed.




