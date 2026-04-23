#!/bin/bash
# Example script to download FASTQ files from SRA and convert to BAM
# This is a template - modify with your actual SRA accessions

echo "=========================================="
echo "Downloading Example Data from SRA"
echo "=========================================="
echo ""

# Install SRA Toolkit if not already installed
# Download from: https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit

# Example SRA accessions (replace with your actual accessions)
MALE_SRA="SRR8585998"      # Replace with your male sample SRA ID
FEMALE_SRA="SRR8585999"    # Replace with your female sample SRA ID

# Create directories
mkdir -p data/fastq
mkdir -p data/bams

echo "Step 1: Downloading FASTQ files from SRA..."
echo ""

# Download male sample
echo "Downloading male sample: $MALE_SRA"
fastq-dump --split-files --gzip --outdir data/fastq $MALE_SRA

# Download female sample
echo "Downloading female sample: $FEMALE_SRA"
fastq-dump --split-files --gzip --outdir data/fastq $FEMALE_SRA

echo ""
echo "Step 2: FASTQ files downloaded to data/fastq/"
echo ""
echo "Next steps:"
echo "1. Verify files are in data/fastq/"
echo "2. Run Step 0 to create BAM files"
echo "3. Then run Step 1 with the BAM files"
echo ""

# List downloaded files
echo "Downloaded files:"
ls -lh data/fastq/




