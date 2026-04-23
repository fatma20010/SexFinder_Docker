#!/bin/bash
# Step 0: Map FASTQ files to reference genome using Bowtie2
# This script runs inside Docker container

set -e  # Exit on error

echo "=========================================="
echo "Step 0: Mapping FASTQ files"
echo "=========================================="
echo ""

# Load config (web API often writes only ADJUSTMENT_COEFFICIENT — must still set sample list paths)
if [ -f /sexfindr/config.sh ]; then
    # shellcheck disable=SC1091
    source /sexfindr/config.sh
else
    echo "WARNING: config.sh not found, using defaults below"
fi
: "${REFERENCE_GENOME:=/sexfindr/ncbi_dataset/ncbi_dataset/data/GCA_907165135.1/GCA_907165135.1_OKI2018_I68_1.0_genomic.fna}"
: "${BOWTIE2_INDEX:=/sexfindr/data/bowtie2_index/Oikopleura_dioica}"
: "${MALE_SAMPLES:=/sexfindr/Step_0/male_samples.txt}"
: "${FEMALE_SAMPLES:=/sexfindr/Step_0/female_samples.txt}"
: "${THREADS:=8}"

echo "Using MALE_SAMPLES=$MALE_SAMPLES"
echo "Using FEMALE_SAMPLES=$FEMALE_SAMPLES"
echo ""

FASTQ_DIR="/sexfindr/data/fastq"
BAM_DIR="/sexfindr/data/bams"

# Create BAM output directory
mkdir -p "$BAM_DIR"

echo "FASTQ directory: $FASTQ_DIR"
ls -la "$FASTQ_DIR" 2>/dev/null || echo "(cannot list FASTQ dir)"
echo ""

# Set globals r1_file, r2_file for a sample ID (lists often use POR25-03_dia while files are POR25-03_R1_paired.fastq.gz)
resolve_fastq_pair() {
    # strip CR so POR25-03_dia\r + %_dia does not become POR25-03\r (would break file match)
    local sample
    sample=$(printf '%s' "$1" | tr -d '\r')
    r1_file=""
    r2_file=""
    local sb="${sample%_dia}"

    if [ -f "$FASTQ_DIR/${sample}_R1.fastq" ] && [ -f "$FASTQ_DIR/${sample}_R2.fastq" ]; then
        r1_file="$FASTQ_DIR/${sample}_R1.fastq"
        r2_file="$FASTQ_DIR/${sample}_R2.fastq"
    elif [ -f "$FASTQ_DIR/${sample}_1.fastq" ] && [ -f "$FASTQ_DIR/${sample}_2.fastq" ]; then
        r1_file="$FASTQ_DIR/${sample}_1.fastq"
        r2_file="$FASTQ_DIR/${sample}_2.fastq"
    elif [ -f "$FASTQ_DIR/${sample}.R1.fastq" ] && [ -f "$FASTQ_DIR/${sample}.R2.fastq" ]; then
        r1_file="$FASTQ_DIR/${sample}.R1.fastq"
        r2_file="$FASTQ_DIR/${sample}.R2.fastq"
    elif [ -f "$FASTQ_DIR/${sample}_R1.fastq.gz" ] && [ -f "$FASTQ_DIR/${sample}_R2.fastq.gz" ]; then
        r1_file="$FASTQ_DIR/${sample}_R1.fastq.gz"
        r2_file="$FASTQ_DIR/${sample}_R2.fastq.gz"
    elif [ -f "$FASTQ_DIR/${sample}_R1_paired.fastq.gz" ] && [ -f "$FASTQ_DIR/${sample}_R2_paired.fastq.gz" ]; then
        r1_file="$FASTQ_DIR/${sample}_R1_paired.fastq.gz"
        r2_file="$FASTQ_DIR/${sample}_R2_paired.fastq.gz"
    elif [ "$sb" != "$sample" ] && [ -f "$FASTQ_DIR/${sb}_R1.fastq.gz" ] && [ -f "$FASTQ_DIR/${sb}_R2.fastq.gz" ]; then
        r1_file="$FASTQ_DIR/${sb}_R1.fastq.gz"
        r2_file="$FASTQ_DIR/${sb}_R2.fastq.gz"
    elif [ "$sb" != "$sample" ] && [ -f "$FASTQ_DIR/${sb}_R1_paired.fastq.gz" ] && [ -f "$FASTQ_DIR/${sb}_R2_paired.fastq.gz" ]; then
        r1_file="$FASTQ_DIR/${sb}_R1_paired.fastq.gz"
        r2_file="$FASTQ_DIR/${sb}_R2_paired.fastq.gz"
    fi
}

# Function to map a sample
map_sample() {
    local sample_id=$1
    local r1_file=$2
    local r2_file=$3

    echo "Mapping sample: $sample_id"
    echo "  R1: $r1_file"
    echo "  R2: $r2_file"

    output_bam="$BAM_DIR/${sample_id}.bam"

    bowtie2 \
        -x "$BOWTIE2_INDEX" \
        -1 "$r1_file" \
        -2 "$r2_file" \
        -X 2000 \
        -p ${THREADS:-8} \
        | samtools view -b -S - \
        | samtools sort - -o "$output_bam"

    samtools index "$output_bam"

    if [ -f "$output_bam" ]; then
        echo "  ✓ Successfully created: $output_bam"
    else
        echo "  ✗ Failed to create BAM file"
        return 1
    fi
    echo ""
}

process_list() {
    local list_file=$1
    local label=$2
    if [ ! -f "$list_file" ]; then
        return 0
    fi
    echo "Processing $label samples..."
    echo ""
    while IFS= read -r sample || [ -n "$sample" ]; do
        sample=$(printf '%s' "$sample" | tr -d '\r' | sed 's/#.*//' | xargs)
        [ -z "$sample" ] && continue

        resolve_fastq_pair "$sample"
        if [ -n "$r1_file" ] && [ -n "$r2_file" ]; then
            map_sample "$sample" "$r1_file" "$r2_file"
        else
            echo "WARNING: FASTQ files not found for sample: $sample"
            echo "  Tried: ${sample}_R1[.fastq|.fastq.gz], …, ${sample}_R1_paired.fastq.gz, and without _dia suffix if present."
            echo ""
        fi
    done < "$list_file"
}

process_list "$MALE_SAMPLES" "male"
process_list "$FEMALE_SAMPLES" "female"

bam_count=$(find "$BAM_DIR" -maxdepth 1 -name '*.bam' -type f 2>/dev/null | wc -l)
bam_count=$(echo "$bam_count" | xargs)
if [ "${bam_count:-0}" -eq 0 ]; then
    echo "ERROR: No BAM files were created in $BAM_DIR."
    echo "  Check: FASTQ files live in $FASTQ_DIR and names match sample IDs (e.g. POR25-03_dia in lists needs POR25-03_R1_paired.fastq.gz if files use POR25-03 without _dia)."
    exit 1
fi

echo "=========================================="
echo "Step 0 Complete! ($bam_count BAM file(s))"
echo "=========================================="
echo ""
echo "BAM files created in: $BAM_DIR"
echo ""
