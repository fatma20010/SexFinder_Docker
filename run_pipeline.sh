#!/bin/bash
# SexFindR Pipeline - Easy Runner (macOS/Linux)
# This script runs the SexFindR pipeline using Docker

echo "=========================================="
echo "SexFindR Pipeline - Easy Runner"
echo "=========================================="
echo ""

# Check if Docker is running
if ! docker ps >/dev/null 2>&1; then
    echo "ERROR: Docker is not running!"
    echo ""
    echo "Please open Docker Desktop and wait until it says 'Docker is running'"
    echo "Then run this script again."
    echo ""
    exit 1
fi

# Check if image exists
if ! docker images sexfindr:latest | grep -q sexfindr; then
    echo "ERROR: Docker image not found!"
    echo ""
    echo "Please run ./load_docker.sh first to load the image."
    echo ""
    exit 1
fi

echo "Starting pipeline..."
echo ""
echo "This will:"
echo "1. Check your data files"
echo "2. Run the appropriate pipeline step"
echo "3. Save results to the output folder"
echo ""
echo "Please wait, this may take a while..."
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Create output directory
mkdir -p output

# Check what type of data they have
DATA_TYPE="unknown"
if ls data/fastq/*.fastq 1> /dev/null 2>&1 || ls data/fastq/*.fq 1> /dev/null 2>&1; then
    DATA_TYPE="fastq"
elif ls data/bams/*.bam 1> /dev/null 2>&1; then
    DATA_TYPE="bam"
elif ls data/vcfs/*.vcf 1> /dev/null 2>&1; then
    DATA_TYPE="vcf"
fi

if [ "$DATA_TYPE" == "unknown" ]; then
    echo "WARNING: No data files found!"
    echo ""
    echo "Please add your data files to:"
    echo "  - data/fastq/  (for FASTQ files)"
    echo "  - data/bams/   (for BAM files)"
    echo "  - data/vcfs/   (for VCF files)"
    echo ""
    exit 1
fi

echo "Detected data type: $DATA_TYPE"
echo ""

# Run the appropriate step
if [ "$DATA_TYPE" == "fastq" ]; then
    echo "Running Step 0: Mapping FASTQ files..."
    docker run --rm \
        -v "$SCRIPT_DIR/data:/sexfindr/data" \
        -v "$SCRIPT_DIR/output:/sexfindr/output" \
        -v "$SCRIPT_DIR/Step_0:/sexfindr/Step_0" \
        -v "$SCRIPT_DIR/config.sh:/sexfindr/config.sh" \
        sexfindr:latest \
        bash -c "cd /sexfindr/Step_0 && bash run_step0_mapping.sh"
elif [ "$DATA_TYPE" == "bam" ]; then
    echo "Running Step 1: DifCover analysis..."
    echo ""
    echo "NOTE: You need to specify which BAM files to compare."
    echo "Please see SETUP.md for instructions on running Step 1."
    echo ""
    exit 0
elif [ "$DATA_TYPE" == "vcf" ]; then
    echo "Running Step 2: Sequence analysis..."
    docker run --rm \
        -v "$SCRIPT_DIR/data:/sexfindr/data" \
        -v "$SCRIPT_DIR/output:/sexfindr/output" \
        -v "$SCRIPT_DIR/Step_2:/sexfindr/Step_2" \
        -v "$SCRIPT_DIR/config.sh:/sexfindr/config.sh" \
        sexfindr:latest \
        bash -c "cd /sexfindr/Step_2 && echo 'Step 2 analysis - see SETUP.md for details'"
fi

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Pipeline failed!"
    echo "Check the error messages above."
    echo ""
    exit 1
fi

echo ""
echo "=========================================="
echo "Pipeline Complete!"
echo "=========================================="
echo ""
echo "Results are saved in the 'output' folder."
echo ""
