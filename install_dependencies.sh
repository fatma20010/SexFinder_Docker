#!/bin/bash
# Bash script to install R dependencies for SexFindR
# Run this script: bash install_dependencies.sh

echo "=========================================="
echo "SexFindR - Installing R Dependencies"
echo "=========================================="
echo ""

# Check if R is installed
if ! command -v Rscript &> /dev/null; then
    echo "ERROR: Rscript is not found in PATH."
    echo "Please install R from https://cran.r-project.org/"
    exit 1
fi

echo "Rscript found: $(which Rscript)"
echo ""

# Read required packages (skip comments and empty lines)
packages=$(grep -v '^#' requirements_R.txt | grep -v '^$' | tr '\n' ',' | sed 's/,$//')

echo "Installing R packages..."
echo ""

# Install packages
Rscript -e "packages <- c($(echo $packages | sed "s/,/','/g" | sed "s/^/'/" | sed "s/$/'/")); new_packages <- packages[!(packages %in% installed.packages()[,'Package'])]; if(length(new_packages)) { install.packages(new_packages, repos='https://cran.rstudio.com/') } else { cat('All packages are already installed.\n') }"

echo ""
echo "Verifying installation..."
Rscript -e "packages <- c($(echo $packages | sed "s/,/','/g" | sed "s/^/'/" | sed "s/$/'/")); for(pkg in packages) { if(require(pkg, character.only=TRUE, quietly=TRUE)) { cat('OK:', pkg, '\n') } else { cat('FAILED:', pkg, '\n') } }"

echo ""
echo "=========================================="
echo "Installation complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Configure config.sh (copy from config_template.sh)"
echo "2. Install bioinformatics tools (bowtie2, samtools, etc.)"
echo "3. Install DifCover from https://github.com/genome/difcover"
echo "4. See SETUP.md for detailed instructions"

