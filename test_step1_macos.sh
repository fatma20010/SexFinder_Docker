#!/bin/bash
# SexFindR Step 1 - macOS Test Script
# This script helps you test Step 1 on macOS

echo "=========================================="
echo "SexFindR Step 1 - macOS Test"
echo "=========================================="
echo ""

# Check if Docker is running
if ! docker ps >/dev/null 2>&1; then
    echo "ERROR: Docker is not running!"
    echo "Please open Docker Desktop and wait until it says 'Docker is running'"
    exit 1
fi

# Check if image exists
if ! docker images sexfindr:latest | grep -q sexfindr; then
    echo "ERROR: Docker image not found!"
    echo "Please run: docker load -i sexfindr_image.tar"
    exit 1
fi

# Get current directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check for BAM files
BAM_COUNT=$(find data/bams -name "*.bam" 2>/dev/null | wc -l | tr -d ' ')

if [ "$BAM_COUNT" -lt 2 ]; then
    echo "ERROR: Need at least 2 BAM files in data/bams/"
    echo "Found: $BAM_COUNT BAM file(s)"
    echo ""
    echo "Please add:"
    echo "  - 1 male BAM file"
    echo "  - 1 female BAM file"
    exit 1
fi

echo "Found $BAM_COUNT BAM file(s)"
echo ""

# List BAM files
echo "BAM files found:"
find data/bams -name "*.bam" | while read bam; do
    echo "  - $(basename $bam)"
done
echo ""

# Ask user to specify which files to use
echo "Please specify:"
read -p "Male BAM filename (from data/bams/): " MALE_BAM
read -p "Female BAM filename (from data/bams/): " FEMALE_BAM
read -p "Adjustment Coefficient (AC) [default: 1.0]: " AC
AC=${AC:-1.0}

# Check files exist
if [ ! -f "data/bams/$MALE_BAM" ]; then
    echo "ERROR: Male BAM file not found: data/bams/$MALE_BAM"
    exit 1
fi

if [ ! -f "data/bams/$FEMALE_BAM" ]; then
    echo "ERROR: Female BAM file not found: data/bams/$FEMALE_BAM"
    exit 1
fi

echo ""
echo "Running Step 1 DifCover analysis..."
echo "  Male BAM: $MALE_BAM"
echo "  Female BAM: $FEMALE_BAM"
echo "  AC: $AC"
echo ""

# Create output directory
mkdir -p output

# Run Step 1
docker run --rm \
    -v "$SCRIPT_DIR/data:/sexfindr/data" \
    -v "$SCRIPT_DIR/Step_1:/sexfindr/Step_1" \
    -v "$SCRIPT_DIR/output:/sexfindr/output" \
    sexfindr:latest \
    bash -c "cd /sexfindr/Step_1 && \
        bash run_difcover.sh \
            /sexfindr/data/bams/$MALE_BAM \
            /sexfindr/data/bams/$FEMALE_BAM \
            $AC"

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "Step 1 completed successfully!"
    echo "=========================================="
    echo ""
    echo "Output files are in: Step_1/"
    echo "Results are in: output/"
    echo ""
    echo "To view results:"
    echo "  ls -lh Step_1/*.DNAcopyout"
    echo ""
else
    echo ""
    echo "ERROR: Step 1 failed!"
    echo "Check the error messages above."
    exit 1
fi




