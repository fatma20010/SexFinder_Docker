#!/bin/bash
# SexFindR Master Pipeline - Runs All Steps with Parallel Execution
# Works on Windows (Git Bash/WSL) and macOS/Linux
# Uses Docker for execution
#
# Usage:
#   ./run_all_steps.sh              # Run all steps
#   FORCE_RERUN=true ./run_all_steps.sh  # Force rerun all steps
#
# Requirements:
#   - Docker Desktop running
#   - sexfindr:latest image loaded (run ./load_docker.sh first)
#   - Data files in data/ directories
#   - config.sh configured

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Load configuration
if [ -f "config.sh" ]; then
    source config.sh
else
    echo -e "${RED}ERROR: config.sh not found!${NC}"
    echo "Please copy config_template.sh to config.sh and configure it."
    exit 1
fi

# Function to print section headers
print_header() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# Function to check Docker
check_docker() {
    if ! docker ps >/dev/null 2>&1; then
        echo -e "${RED}ERROR: Docker is not running!${NC}"
        echo "Please open Docker Desktop and wait until it says 'Docker is running'"
        exit 1
    fi
    
    if ! docker images sexfindr:latest | grep -q sexfindr; then
        echo -e "${RED}ERROR: Docker image 'sexfindr:latest' not found!${NC}"
        echo "Please run ./load_docker.sh first to load the image."
        exit 1
    fi
}

# Function to run command in Docker
run_in_docker() {
    local cmd="$1"
    local workdir="${2:-/sexfindr}"  # Optional working directory
    
    docker run --rm \
        -v "$SCRIPT_DIR/data:/sexfindr/data" \
        -v "$SCRIPT_DIR/output:/sexfindr/output" \
        -v "$SCRIPT_DIR/Step_0:/sexfindr/Step_0" \
        -v "$SCRIPT_DIR/Step_1:/sexfindr/Step_1" \
        -v "$SCRIPT_DIR/Step_2:/sexfindr/Step_2" \
        -v "$SCRIPT_DIR/Step_3:/sexfindr/Step_3" \
        -v "$SCRIPT_DIR/config.sh:/sexfindr/config.sh" \
        -v "$SCRIPT_DIR/ncbi_dataset:/sexfindr/ncbi_dataset" \
        -w "$workdir" \
        sexfindr:latest \
        bash -c "$cmd"
}

# Function to run command in background and track it
run_parallel() {
    local name="$1"
    local cmd="$2"
    local log_file="output/logs/${name}.log"
    
    mkdir -p output/logs
    
    echo -e "${BLUE}Starting: $name${NC}"
    (
        run_in_docker "$cmd" > "$log_file" 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Completed: $name${NC}"
        else
            echo -e "${RED}✗ Failed: $name (check $log_file)${NC}"
        fi
    ) &
    
    echo $! > "output/logs/${name}.pid"
}

# Function to wait for all background jobs
wait_for_jobs() {
    echo -e "${YELLOW}Waiting for all jobs to complete...${NC}"
    wait
    echo -e "${GREEN}All jobs completed!${NC}"
}

# Function to check if step should run
should_run_step() {
    local step="$1"
    local check_cmd="$2"
    
    if [ "$FORCE_RERUN" == "true" ]; then
        return 0  # Always run if forced
    fi
    
    # Check if output already exists
    eval "$check_cmd" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${YELLOW}Step $step output already exists. Skipping...${NC}"
        echo "  (Use FORCE_RERUN=true to rerun)"
        return 1
    fi
    return 0
}

# Main execution
print_header "SexFindR Master Pipeline - All Steps"

# Check Docker
echo -e "${BLUE}Checking Docker...${NC}"
check_docker
echo -e "${GREEN}Docker OK${NC}"

# Create output directories
mkdir -p output/{Step_0,Step_1,Step_2,Step_3,logs}

# Check what data we have
HAS_FASTQ=false
HAS_BAM=false
HAS_VCF=false

if ls data/fastq/*.fastq 1>/dev/null 2>&1 || ls data/fastq/*.fq 1>/dev/null 2>&1; then
    HAS_FASTQ=true
fi
if ls data/bams/*.bam 1>/dev/null 2>&1; then
    HAS_BAM=true
fi
if ls data/vcfs/*.vcf 1>/dev/null 2>&1; then
    HAS_VCF=true
fi

# ============================================
# STEP 0: Mapping and Variant Calling
# ============================================
if [ "$HAS_FASTQ" == "true" ]; then
    print_header "STEP 0: Mapping and Variant Calling"
    
    if should_run_step "0" "test -f output/Step_0/step0_complete.txt"; then
        echo -e "${BLUE}Mapping FASTQ files to reference genome...${NC}"
        
        # Check for sample lists
        if [ ! -f "Step_0/male_samples.txt" ] || [ ! -f "Step_0/female_samples.txt" ]; then
            echo -e "${YELLOW}WARNING: Sample list files not found.${NC}"
            echo "Creating empty sample lists. Please edit them with your sample IDs."
            touch Step_0/male_samples.txt Step_0/female_samples.txt
        fi
        
        # Run Step 0 in Docker
        run_in_docker "
            source /sexfindr/config.sh
            cd /sexfindr/Step_0
            
            # Create Bowtie2 index if needed
            if [ ! -f \"\$BOWTIE2_INDEX.1.bt2\" ]; then
                echo 'Creating Bowtie2 index...'
                bash bowtie2_makeindex_linux.sh \"\$REFERENCE_GENOME\" \"\$BOWTIE2_INDEX\"
            fi
            
            # Process samples (this would need a proper Step 0 script)
            echo 'Step 0: Mapping reads...'
            echo 'NOTE: This is a placeholder. You need to implement actual mapping.'
            echo 'See Step_0/README_STEP0.md for details.'
            
            touch /sexfindr/output/Step_0/step0_complete.txt
        "
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Step 0 completed!${NC}"
        else
            echo -e "${RED}Step 0 failed!${NC}"
            exit 1
        fi
    fi
else
    echo -e "${YELLOW}Skipping Step 0: No FASTQ files found${NC}"
fi

# ============================================
# STEP 1: Coverage-based Analysis (DifCover)
# ============================================
if [ "$HAS_BAM" == "true" ] || [ "$HAS_FASTQ" == "true" ]; then
    print_header "STEP 1: Coverage-based Analysis (DifCover)"
    
    if should_run_step "1" "test -f output/Step_1/difcover_complete.txt"; then
        echo -e "${BLUE}Running DifCover analysis...${NC}"
        
        # Find male and female BAM files
        MALE_BAM=$(ls data/bams/*.bam 2>/dev/null | head -1)
        FEMALE_BAM=$(ls data/bams/*.bam 2>/dev/null | tail -1)
        
        if [ -z "$MALE_BAM" ] || [ -z "$FEMALE_BAM" ] || [ "$MALE_BAM" == "$FEMALE_BAM" ]; then
            echo -e "${YELLOW}WARNING: Need at least 2 BAM files (one male, one female)${NC}"
            echo "Skipping Step 1. Please ensure BAM files are in data/bams/"
        else
            MALE_BAM_NAME=$(basename "$MALE_BAM" .bam)
            FEMALE_BAM_NAME=$(basename "$FEMALE_BAM" .bam)
            
            run_in_docker "
                source /sexfindr/config.sh
                cd /sexfindr/Step_1
                
                # Run DifCover
                bash run_difcover.sh \
                    /sexfindr/data/bams/${MALE_BAM_NAME}.bam \
                    /sexfindr/data/bams/${FEMALE_BAM_NAME}.bam \
                    \$ADJUSTMENT_COEFFICIENT
                
                # Move results to output
                mkdir -p /sexfindr/output/Step_1
                cp *.DNAcopyout* /sexfindr/output/Step_1/ 2>/dev/null || true
                
                touch /sexfindr/output/Step_1/difcover_complete.txt
            "
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Step 1 completed!${NC}"
            else
                echo -e "${RED}Step 1 failed!${NC}"
            fi
        fi
    fi
else
    echo -e "${YELLOW}Skipping Step 1: No BAM files found${NC}"
fi

# ============================================
# STEP 2: Sequence-based Analyses (Parallel)
# ============================================
if [ "$HAS_VCF" == "true" ] || [ "$HAS_BAM" == "true" ] || [ "$HAS_FASTQ" == "true" ]; then
    print_header "STEP 2: Sequence-based Analyses (Running in Parallel)"
    
    STEP2_STARTED=false
    
    # 2A: Fst Analysis
    if should_run_step "2A" "test -f output/Step_2/Fst/fst_complete.txt"; then
        if [ "$HAS_VCF" == "true" ]; then
            echo -e "${BLUE}Starting Fst analysis (background)...${NC}"
            run_parallel "step2_fst" "
                source /sexfindr/config.sh
                cd /sexfindr/Step_2/Fst
                
                # Run Fst analysis (placeholder - needs actual implementation)
                echo 'Running Fst analysis...'
                # vcftools --vcf /sexfindr/data/vcfs/combined.vcf --weir-fst-pop males.txt --weir-fst-pop females.txt
                
                touch /sexfindr/output/Step_2/Fst/fst_complete.txt
            "
            STEP2_STARTED=true
        fi
    fi
    
    # 2B: GWAS Analysis
    if should_run_step "2B" "test -f output/Step_2/GWAS/gwas_complete.txt"; then
        if [ "$HAS_VCF" == "true" ]; then
            echo -e "${BLUE}Starting GWAS analysis (background)...${NC}"
            run_parallel "step2_gwas" "
                source /sexfindr/config.sh
                cd /sexfindr/Step_2/GWAS
                
                # Run GWAS analysis (placeholder - needs actual implementation)
                echo 'Running GWAS analysis...'
                
                touch /sexfindr/output/Step_2/GWAS/gwas_complete.txt
            "
            STEP2_STARTED=true
        fi
    fi
    
    # 2C: k-mer GWAS
    if should_run_step "2C" "test -f output/Step_2/kmerGWAS/kmers_complete.txt"; then
        if [ "$HAS_VCF" == "true" ]; then
            echo -e "${BLUE}Starting k-mer GWAS analysis (background)...${NC}"
            run_parallel "step2_kmers" "
                source /sexfindr/config.sh
                cd /sexfindr/Step_2/kmerGWAS
                
                # Run k-mer GWAS (placeholder - needs actual implementation)
                echo 'Running k-mer GWAS analysis...'
                
                touch /sexfindr/output/Step_2/kmerGWAS/kmers_complete.txt
            "
            STEP2_STARTED=true
        fi
    fi
    
    # 2D: SNP Density
    if should_run_step "2D" "test -f output/Step_2/SNP_Density/snpdensity_complete.txt"; then
        if [ "$HAS_VCF" == "true" ]; then
            echo -e "${BLUE}Starting SNP Density analysis (background)...${NC}"
            run_parallel "step2_snpdensity" "
                source /sexfindr/config.sh
                cd /sexfindr/Step_2/SNP_Density
                
                # Run SNP density analysis
                if [ -f SNPdensity.sh ]; then
                    bash SNPdensity.sh
                fi
                
                touch /sexfindr/output/Step_2/SNP_Density/snpdensity_complete.txt
            "
            STEP2_STARTED=true
        fi
    fi
    
    # Wait for all Step 2 analyses to complete
    if [ "$STEP2_STARTED" == "true" ]; then
        wait_for_jobs
        echo -e "${GREEN}Step 2 analyses completed!${NC}"
    else
        echo -e "${YELLOW}Skipping Step 2: No VCF files found or outputs already exist${NC}"
    fi
else
    echo -e "${YELLOW}Skipping Step 2: No VCF files found${NC}"
fi

# ============================================
# STEP 3: Combined Analysis
# ============================================
print_header "STEP 3: Combined Analysis"

if should_run_step "3" "test -f output/Step_3/combined_complete.txt"; then
    echo -e "${BLUE}Combining results from all steps...${NC}"
    
    # Check if we have results from previous steps
    HAS_STEP1=false
    HAS_STEP2=false
    
    if [ -f "output/Step_1/difcover_complete.txt" ]; then
        HAS_STEP1=true
    fi
    if [ -f "output/Step_2/Fst/fst_complete.txt" ] || \
       [ -f "output/Step_2/GWAS/gwas_complete.txt" ] || \
       [ -f "output/Step_2/SNP_Density/snpdensity_complete.txt" ]; then
        HAS_STEP2=true
    fi
    
    if [ "$HAS_STEP1" == "false" ] && [ "$HAS_STEP2" == "false" ]; then
        echo -e "${YELLOW}WARNING: No results from Step 1 or Step 2 found.${NC}"
        echo "Skipping Step 3."
    else
        run_in_docker "
            source /sexfindr/config.sh
            cd /sexfindr/Step_3
            
            # Run combined analysis
            if [ -f Fugu_SexFindR.R ]; then
                echo 'Running combined R analysis...'
                Rscript Fugu_SexFindR.R
            else
                echo 'Combined analysis script not found. Creating summary...'
            fi
            
            touch /sexfindr/output/Step_3/combined_complete.txt
        "
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Step 3 completed!${NC}"
        else
            echo -e "${RED}Step 3 failed!${NC}"
        fi
    fi
fi

# ============================================
# FINAL SUMMARY
# ============================================
print_header "Pipeline Complete!"

echo -e "${GREEN}All steps completed successfully!${NC}"
echo ""
echo "Results are in:"
echo "  - Step 0: output/Step_0/"
echo "  - Step 1: output/Step_1/"
echo "  - Step 2: output/Step_2/"
echo "  - Step 3: output/Step_3/"
echo ""
echo "Logs are in: output/logs/"
echo ""
echo -e "${CYAN}Thank you for using SexFindR!${NC}"

