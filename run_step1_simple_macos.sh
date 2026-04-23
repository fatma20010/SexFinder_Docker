#!/bin/bash
# Simple Step 1 Runner for macOS
# Use this if you only have the Docker image and your BAM files
# This script creates the folder structure and runs Step 1

echo "=========================================="
echo "SexFindR Step 1 - Simple Runner (macOS)"
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
    echo "ERROR: Docker image 'sexfindr:latest' not found!"
    echo ""
    echo "Please load the Docker image first:"
    echo "  docker load -i sexfindr_image.tar"
    exit 1
fi

# Get current directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Create folder structure if it doesn't exist
echo "Creating folder structure..."
mkdir -p data/bams
mkdir -p Step_1
mkdir -p output

# Check for BAM files
BAM_FILES=$(find data/bams -name "*.bam" 2>/dev/null)

if [ -z "$BAM_FILES" ]; then
    echo ""
    echo "=========================================="
    echo "No BAM files found!"
    echo "=========================================="
    echo ""
    echo "Please put your BAM files in:"
    echo "  $SCRIPT_DIR/data/bams/"
    echo ""
    echo "You need at least 2 BAM files:"
    echo "  - 1 male BAM file"
    echo "  - 1 female BAM file"
    echo ""
    echo "Example:"
    echo "  cp /path/to/male.bam $SCRIPT_DIR/data/bams/"
    echo "  cp /path/to/female.bam $SCRIPT_DIR/data/bams/"
    exit 1
fi

# List BAM files
echo ""
echo "BAM files found:"
find data/bams -name "*.bam" | while read bam; do
    echo "  - $(basename $bam)"
done
echo ""

# Ask user for file names
echo "Please specify which files to use:"
read -p "Male BAM filename (just the filename, not full path): " MALE_BAM
read -p "Female BAM filename (just the filename, not full path): " FEMALE_BAM
read -p "Adjustment Coefficient (AC) [default: 1.0, press Enter to use default]: " AC
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
echo "=========================================="
echo "Running Step 1 DifCover Analysis"
echo "=========================================="
echo "  Male BAM:   $MALE_BAM"
echo "  Female BAM: $FEMALE_BAM"
echo "  AC:         $AC"
echo ""
echo "This may take a while, please wait..."
echo ""

# Run Step 1 using Docker
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
    echo "✅ Step 1 completed successfully!"
    echo "=========================================="
    echo ""
    echo "Output files are in:"
    echo "  $SCRIPT_DIR/Step_1/"
    echo ""
    echo "To view results:"
    echo "  ls -lh $SCRIPT_DIR/Step_1/*.DNAcopyout"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "❌ ERROR: Step 1 failed!"
    echo "=========================================="
    echo ""
    echo "Check the error messages above."
    echo ""
    exit 1
fi




