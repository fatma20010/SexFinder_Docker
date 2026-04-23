#!/bin/bash
# Setup Script - Creates folder structure for SexFindR
# Use this if you only have the run scripts

echo "=========================================="
echo "SexFindR Project Setup"
echo "=========================================="
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Ask user where to create the project
read -p "Where do you want to create the project? [default: ~/Desktop/SexFindR_Project]: " PROJECT_DIR
PROJECT_DIR=${PROJECT_DIR:-~/Desktop/SexFindR_Project}

# Expand ~ to home directory
PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"

echo ""
echo "Creating project folder at: $PROJECT_DIR"
echo ""

# Create folder structure
mkdir -p "$PROJECT_DIR/data/fastq"
mkdir -p "$PROJECT_DIR/data/bams"
mkdir -p "$PROJECT_DIR/data/vcfs"
mkdir -p "$PROJECT_DIR/Step_0"
mkdir -p "$PROJECT_DIR/Step_1"
mkdir -p "$PROJECT_DIR/Step_2"
mkdir -p "$PROJECT_DIR/Step_3"
mkdir -p "$PROJECT_DIR/output"

echo "✅ Created folder structure"
echo ""

# Copy scripts if they exist in current directory
if [ -f "$SCRIPT_DIR/run_pipeline.sh" ]; then
    cp "$SCRIPT_DIR/run_pipeline.sh" "$PROJECT_DIR/"
    chmod +x "$PROJECT_DIR/run_pipeline.sh"
    echo "✅ Copied run_pipeline.sh"
fi

if [ -f "$SCRIPT_DIR/run_all_steps.sh" ]; then
    cp "$SCRIPT_DIR/run_all_steps.sh" "$PROJECT_DIR/"
    chmod +x "$PROJECT_DIR/run_all_steps.sh"
    echo "✅ Copied run_all_steps.sh"
fi

# Create minimal config.sh
cat > "$PROJECT_DIR/config.sh" << 'EOF'
#!/bin/bash
# Minimal config for SexFindR

# Base directory
SEXFINDR_DIR="${PWD}"

# Adjustment Coefficient for Step 1 (start with 1.0, adjust if needed)
ADJUSTMENT_COEFFICIENT=1.0

# Reference genome (uncomment and set if needed)
# REFERENCE_GENOME="/path/to/reference.fa"

# Bowtie2 index (uncomment and set if needed)
# BOWTIE2_INDEX="/path/to/index"
EOF

chmod +x "$PROJECT_DIR/config.sh"
echo "✅ Created config.sh"

# Create sample list templates
cat > "$PROJECT_DIR/Step_0/male_samples.txt" << 'EOF'
# Male sample IDs - one per line
# Replace these with your actual sample IDs
# Example:
# male_sample_1
# male_sample_2
EOF

cat > "$PROJECT_DIR/Step_0/female_samples.txt" << 'EOF'
# Female sample IDs - one per line
# Replace these with your actual sample IDs
# Example:
# female_sample_1
# female_sample_2
EOF

echo "✅ Created sample list templates"
echo ""

# Create README
cat > "$PROJECT_DIR/README.txt" << EOF
SexFindR Project Folder
=======================

Folder Structure:
-----------------
data/
  ├── fastq/     ← Put FASTQ files here (if you have them)
  ├── bams/      ← PUT YOUR BAM FILES HERE
  └── vcfs/      ← Put VCF files here (if you have them)

Step_0/
  ├── male_samples.txt    ← Edit with your male sample IDs
  └── female_samples.txt  ← Edit with your female sample IDs

Step_1/  ← Outputs from Step 1
Step_2/  ← Outputs from Step 2
Step_3/  ← Outputs from Step 3
output/  ← Final results

Next Steps:
-----------
1. Put your BAM files in: data/bams/
2. Edit Step_0/male_samples.txt and Step_0/female_samples.txt
3. Run: ./run_all_steps.sh

For more help, see DATA_ORGANIZATION_FOR_SCRIPTS.md
EOF

echo "✅ Created README.txt"
echo ""

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Project folder created at:"
echo "  $PROJECT_DIR"
echo ""
echo "Next steps:"
echo "  1. Put your BAM files in: $PROJECT_DIR/data/bams/"
echo "  2. Edit sample lists in: $PROJECT_DIR/Step_0/"
echo "  3. Run: cd $PROJECT_DIR && ./run_all_steps.sh"
echo ""
echo "To add your data files:"
echo "  cp /path/to/your/*.bam $PROJECT_DIR/data/bams/"
echo ""




