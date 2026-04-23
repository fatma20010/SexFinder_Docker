#!/bin/bash
# Configuration template for SexFindR pipeline
# Copy this file to config.sh and modify paths according to your system

# Base directory for SexFindR
SEXFINDR_DIR="${PWD}"

# DifCover scripts directory (download from: https://github.com/genome/difcover)
DIFCOVER_DIR="/path/to/difcover/scripts"

# Reference genome path
REFERENCE_GENOME="/path/to/reference/genome.fa"

# Bowtie2 index prefix (without .bt2 extension)
BOWTIE2_INDEX="/path/to/bowtie2/index/prefix"

# Input data directories
BAM_DIR="${SEXFINDR_DIR}/data/bams"
VCF_DIR="${SEXFINDR_DIR}/data/vcfs"
FASTQ_DIR="${SEXFINDR_DIR}/data/fastq"

# Output directory
OUTPUT_DIR="${SEXFINDR_DIR}/output"

# Sample lists
MALE_SAMPLES="${SEXFINDR_DIR}/Step_0/male_samples.txt"
FEMALE_SAMPLES="${SEXFINDR_DIR}/Step_0/female_samples.txt"

# Computational resources
THREADS=16
MEMORY="32G"

# Step 1 - DifCover parameters
MIN_COV_SAMPLE1=10
MAX_COV_SAMPLE1=219
MIN_COV_SAMPLE2=10
MAX_COV_SAMPLE2=240
TARGET_VALID_BASES=1000
MIN_WINDOW_SIZE=500
ADJUSTMENT_COEFFICIENT=1
ENRICHMENT_THRESHOLD=0.7369656

# Step 2 - Analysis parameters
WINDOW_SIZE=10000
FST_THRESHOLD=0.05
GWAS_TOP_PERCENT=5

# Step 3 - Combined analysis parameters
SNP_DENSITY_TOP_RANK=100
GWAS_TOP_RANK=100
FST_TOP_RANK=100

