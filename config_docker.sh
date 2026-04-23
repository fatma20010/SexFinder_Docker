#!/bin/bash
# Configuration for SexFindR pipeline (Docker version)
# This file is used as a template inside the Docker container

# Base directory for SexFindR
SEXFINDR_DIR="/sexfindr"

# DifCover scripts directory
DIFCOVER_DIR="/sexfindr/DifCover/dif_cover_scripts"

# Reference genome path (if included in image)
REFERENCE_GENOME="/sexfindr/ncbi_dataset/ncbi_dataset/data/GCA_907165135.1/GCA_907165135.1_OKI2018_I68_1.0_genomic.fna"

# Bowtie2 index prefix (if included in image)
BOWTIE2_INDEX="/sexfindr/data/bowtie2_index/Oikopleura_dioica"

# Input data directories
BAM_DIR="/sexfindr/data/bams"
VCF_DIR="/sexfindr/data/vcfs"
FASTQ_DIR="/sexfindr/data/fastq"

# Output directory
OUTPUT_DIR="/sexfindr/output"

# Sample lists
MALE_SAMPLES="/sexfindr/Step_0/male_samples.txt"
FEMALE_SAMPLES="/sexfindr/Step_0/female_samples.txt"

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

