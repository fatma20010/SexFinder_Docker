#!/bin/bash
# Calculate Adjustment Coefficient (AC) for Step 1
# This script calculates modal depths for all BAM files

echo "Calculating modal depths for BAM files..."
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if Docker is running
if ! docker ps >/dev/null 2>&1; then
    echo "ERROR: Docker is not running!"
    exit 1
fi

# Check for BAM files
if [ ! -d "data/bams" ] || [ -z "$(ls -A data/bams/*.bam 2>/dev/null)" ]; then
    echo "ERROR: No BAM files found in data/bams/"
    exit 1
fi

echo "Processing BAM files..."
echo ""

for bam in data/bams/*.bam; do
    if [ -f "$bam" ]; then
        BAM_NAME=$(basename "$bam")
        echo "Processing: $BAM_NAME"
        
        docker run --rm \
            -v "$SCRIPT_DIR/data:/sexfindr/data" \
            sexfindr:latest \
            bash -c "cd /sexfindr/data/bams && \
                samtools stats $BAM_NAME > temp_stats 2>/dev/null && \
                number=\$(grep ^COV temp_stats | cut -f 2- | awk -v max=0 '{if(\$3>max){want=\$2; max=\$3}}END{print want}') && \
                echo \"  Modal depth: \$number\" && \
                rm -f temp_stats" 2>/dev/null || echo "  Could not calculate modal depth"
    fi
done

echo ""
echo "=========================================="
echo "To calculate AC:"
echo "  AC = (Female modal depth) / (Male modal depth)"
echo ""
echo "Example:"
echo "  If Female modal depth = 50 and Male modal depth = 45"
echo "  Then AC = 50/45 = 1.11"
echo ""
echo "If modal depth calculation fails, you can:"
echo "  1. Use AC = 1.0 (if coverage is similar)"
echo "  2. Use ratio of BAM file sizes as rough estimate"
echo "=========================================="




