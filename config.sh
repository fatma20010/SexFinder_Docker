#!/bin/bash
# Configuration template for SexFindR pipeline
# Copy this file to config.sh and modify paths according to your system

# Base directory for SexFindR
SEXFINDR_DIR="${PWD}"

# DifCover scripts directory (download from: https://github.com/timnat/DifCover)
# NOTE: The actual scripts directory is called "dif_cover_scripts" in the DifCover repository
DIFCOVER_DIR="/c/Users/msi/DifCover/dif_cover_scripts"

# Reference genome path (Oikopleura dioica - OKI2018_I68_1.0)
REFERENCE_GENOME="${SEXFINDR_DIR}/ncbi_dataset/ncbi_dataset/data/GCA_907165135.1/GCA_907165135.1_OKI2018_I68_1.0_genomic.fna"

# Bowtie2 index prefix (without .bt2 extension)
# Index will be created in: data/bowtie2_index/Oikopleura_dioica
BOWTIE2_INDEX="${SEXFINDR_DIR}/data/bowtie2_index/Oikopleura_dioica"

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
THREADS=8
MEMORY="16G"

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

