# Dockerfile for SexFindR Pipeline
# This image contains all dependencies and the pipeline setup
# Users just need to mount their data directory

FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies (include bedtools for DifCover)
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    python3 \
    python3-pip \
    unzip \
    libbz2-dev \
    liblzma-dev \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    ca-certificates \
    bedtools \
    && rm -rf /var/lib/apt/lists/*

# Install R
RUN apt-get update && apt-get install -y \
    r-base \
    r-base-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN Rscript -e "install.packages(c('tidyverse', 'patchwork', 'ggpubr', 'ggthemes'), repos='https://cran.rstudio.com/')"

# DNAcopy (Bioconductor) — required for DifCover stage 3 (from_ratio_per_window__to__DNAcopy_output.sh)
RUN Rscript -e "install.packages('BiocManager', repos='https://cran.rstudio.com/')" && \
    Rscript -e "BiocManager::install(c('DNAcopy'), ask=FALSE, update=FALSE)"

# Install SAMtools
RUN cd /tmp && \
    wget https://github.com/samtools/samtools/releases/download/1.19/samtools-1.19.tar.bz2 && \
    tar -xjf samtools-1.19.tar.bz2 && \
    cd samtools-1.19 && \
    ./configure && \
    make && \
    make install && \
    rm -rf /tmp/samtools-1.19*

# Install Bowtie2
RUN cd /tmp && \
    wget https://github.com/BenLangmead/bowtie2/releases/download/v2.5.2/bowtie2-2.5.2-linux-x86_64.zip && \
    unzip bowtie2-2.5.2-linux-x86_64.zip && \
    mv bowtie2-2.5.2-linux-x86_64 /usr/local/bowtie2 && \
    ln -s /usr/local/bowtie2/bowtie2 /usr/local/bin/bowtie2 && \
    ln -s /usr/local/bowtie2/bowtie2-build /usr/local/bin/bowtie2-build && \
    rm -rf /tmp/bowtie2-2.5.2-linux-x86_64.zip

# Install VCFtools (optional, for Step 2)
RUN cd /tmp && \
    wget https://github.com/vcftools/vcftools/releases/download/v0.1.16/vcftools-0.1.16.tar.gz && \
    tar -xzf vcftools-0.1.16.tar.gz && \
    cd vcftools-0.1.16 && \
    ./configure && \
    make && \
    make install && \
    rm -rf /tmp/vcftools-0.1.16*

# Set working directory
WORKDIR /sexfindr

# Copy SexFindR pipeline files
COPY . /sexfindr/

# Clone DifCover
RUN git clone https://github.com/timnat/DifCover.git /sexfindr/DifCover || true && \
    if [ -d "/sexfindr/DifCover" ]; then \
        echo "DifCover cloned successfully"; \
    else \
        echo "Warning: DifCover clone failed, will need to be configured manually"; \
    fi

# Patch DifCover shell scripts only (do not sed binaries or .cpp — sed can corrupt ELF and break stage 2)
RUN if [ -d "/sexfindr/DifCover/dif_cover_scripts" ]; then \
        find /sexfindr/DifCover/dif_cover_scripts -type f -name '*.sh' -exec sed -i 's/genomeCoverageBed/bedtools genomecov/g' {} \; 2>/dev/null || true && \
        find /sexfindr/DifCover/dif_cover_scripts -type f -name '*.sh' -exec sed -i 's/unionBedGraphs/bedtools unionbedg/g' {} \; 2>/dev/null || true; \
    fi

# Fix upstream DifCover bug: fname[] uninitialized before strncat (vendor fixed .cpp — do not patch at runtime)
RUN if [ -f /sexfindr/Step_1/patches/from_unionbed_to_ratio_per_window_CC0.cpp ]; then \
        cp -f /sexfindr/Step_1/patches/from_unionbed_to_ratio_per_window_CC0.cpp \
            /sexfindr/DifCover/dif_cover_scripts/from_unionbed_to_ratio_per_window_CC0.cpp; \
    fi

# Build the DifCover C++ helper (required for stage 2+). The repo may ship a binary, but compiling
# from source guarantees it exists and matches the image architecture.
RUN if [ -f /sexfindr/DifCover/dif_cover_scripts/Makefile ]; then \
        cd /sexfindr/DifCover/dif_cover_scripts && rm -f from_unionbed_to_ratio_per_window_CC0 && make && \
        chmod +x from_unionbed_to_ratio_per_window_CC0 && \
        test -x from_unionbed_to_ratio_per_window_CC0 || \
        (echo "ERROR: from_unionbed_to_ratio_per_window_CC0 not built" && exit 1); \
    fi

# Make all DifCover scripts and binaries executable (fixes "Permission denied" on from_unionbed_to_ratio_per_window_CC0)
RUN if [ -d "/sexfindr/DifCover/dif_cover_scripts" ]; then chmod +x /sexfindr/DifCover/dif_cover_scripts/* 2>/dev/null || true; fi

# Create data directories
RUN mkdir -p /sexfindr/data/{fastq,bams,vcfs,bowtie2_index} && \
    mkdir -p /sexfindr/output

# Make scripts executable
RUN find /sexfindr -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true && \
    chmod +x /sexfindr/run_pipeline.sh 2>/dev/null || true

# Create Docker-ready config.sh if config_docker.sh exists, otherwise use template
RUN if [ -f "/sexfindr/config_docker.sh" ]; then \
        cp /sexfindr/config_docker.sh /sexfindr/config.sh && \
        chmod +x /sexfindr/config.sh; \
    elif [ ! -f "/sexfindr/config.sh" ]; then \
        cp /sexfindr/config_template.sh /sexfindr/config.sh && \
        sed -i 's|SEXFINDR_DIR="${PWD}"|SEXFINDR_DIR="/sexfindr"|g' /sexfindr/config.sh && \
        sed -i 's|DIFCOVER_DIR="/path/to/difcover/scripts"|DIFCOVER_DIR="/sexfindr/DifCover/dif_cover_scripts"|g' /sexfindr/config.sh && \
        sed -i 's|REFERENCE_GENOME="/path/to/reference/genome.fa"|REFERENCE_GENOME="/sexfindr/ncbi_dataset/ncbi_dataset/data/GCA_907165135.1/GCA_907165135.1_OKI2018_I68_1.0_genomic.fna"|g' /sexfindr/config.sh && \
        sed -i 's|BOWTIE2_INDEX="/path/to/bowtie2/index/prefix"|BOWTIE2_INDEX="/sexfindr/data/bowtie2_index/Oikopleura_dioica"|g' /sexfindr/config.sh && \
        chmod +x /sexfindr/config.sh; \
    fi

# Set environment variables
ENV PATH="/usr/local/bowtie2:/usr/local/bin:${PATH}"
ENV SEXFINDR_DIR=/sexfindr

# Default command - just provide bash shell
CMD ["/bin/bash"]

