# Docker Setup for SexFindR Pipeline

This Docker image contains all dependencies needed to run the SexFindR pipeline. Users only need to add their data files.

## For the Professor (Quick Start)

### Prerequisites
- Docker installed on your system
- Your sequencing data files (FASTQ, BAM, or VCF)

### Quick Start

1. **Get the Docker image** (if provided as a file):
   ```bash
   docker load -i sexfindr_image.tar
   ```

2. **Prepare your data**:
   - Place your FASTQ files in: `data/fastq/`
   - Or place your BAM files in: `data/bams/`
   - Or place your VCF files in: `data/vcfs/`

3. **Add sample IDs**:
   - Edit `Step_0/male_samples.txt` with your male sample IDs (one per line)
   - Edit `Step_0/female_samples.txt` with your female sample IDs (one per line)

4. **Run the container**:
   ```bash
   docker run -it --rm \
     -v $(pwd)/data:/sexfindr/data \
     -v $(pwd)/output:/sexfindr/output \
     -v $(pwd)/config.sh:/sexfindr/config.sh \
     sexfindr:latest \
     /bin/bash
   ```

5. **Inside the container, run the pipeline**:
   ```bash
   # For FASTQ files (Step 0):
   cd Step_0
   bash run_step0_mapping.sh
   
   # For BAM files (Step 1):
   cd Step_1
   bash run_difcover.sh <male_bam> <female_bam> <adjustment_coefficient>
   ```

### Using Docker Compose (Easier)

1. **Start the container**:
   ```bash
   docker-compose up -d
   ```

2. **Enter the container**:
   ```bash
   docker-compose exec sexfindr bash
   ```

3. **Run your analysis** inside the container

4. **Stop the container**:
   ```bash
   docker-compose down
   ```

## What's Included in the Image

- ✅ R and required R packages (tidyverse, patchwork, ggpubr, ggthemes)
- ✅ Bowtie2 (for read mapping)
- ✅ SAMtools (for BAM file processing)
- ✅ VCFtools (for variant analysis)
- ✅ Python 3
- ✅ SexFindR pipeline scripts
- ✅ DifCover (cloned during build)
- ✅ Reference genome and Bowtie2 index (if included)

## Data Organization

Your data should be organized like this:

```
your_project/
├── data/
│   ├── fastq/          # Your FASTQ files here
│   ├── bams/           # Or BAM files here
│   └── vcfs/           # Or VCF files here
├── Step_0/
│   ├── male_samples.txt    # Your male sample IDs
│   └── female_samples.txt  # Your female sample IDs
├── config.sh           # Configuration file
└── output/             # Results will appear here
```

## Configuration

The `config.sh` file is pre-configured with:
- Reference genome: Oikopleura dioica (OKI2018_I68_1.0)
- Bowtie2 index path
- DifCover path
- Data directory paths

You can modify `config.sh` if needed before running.

## Troubleshooting

### Permission Issues
If you get permission errors, try:
```bash
docker run -it --rm --user $(id -u):$(id -g) ...
```

### Large Files
For large datasets, ensure Docker has enough disk space:
```bash
docker system df  # Check disk usage
```

### Memory Issues
Increase Docker memory limit in Docker Desktop settings if needed.

## Support

For issues or questions, refer to:
- `SETUP.md` - Detailed setup instructions
- `QUICK_START.md` - Quick reference guide
- https://sexfindr.readthedocs.io/ - Full documentation


