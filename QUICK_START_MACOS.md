# Quick Start Guide - macOS

## For macOS Users

The SexFindR pipeline is ready to run on macOS! Follow these simple steps:

### 1. Install Docker Desktop for Mac
- Download from: https://www.docker.com/products/docker-desktop
- Choose the version for your Mac (Intel or Apple Silicon)
- Install and start Docker Desktop

### 2. Load the Docker Image

Open Terminal and navigate to the SexFindR folder:
```bash
cd /path/to/SexFindR
```

Make scripts executable:
```bash
chmod +x load_docker.sh run_pipeline.sh
```

Load the image:
```bash
./load_docker.sh
```

### 3. Add Your Data

- Place FASTQ files in: `data/fastq/`
- Or place BAM files in: `data/bams/`
- Or place VCF files in: `data/vcfs/`
- Edit `Step_0/male_samples.txt` and `Step_0/female_samples.txt` with your sample names

### 4. Run the Pipeline

```bash
./run_pipeline.sh
```

Results will be in the `output/` folder.

## Files for macOS

- `load_docker.sh` - Load the Docker image
- `run_pipeline.sh` - Run the pipeline
- `FOR_PROFESSOR_MACOS.md` - Detailed instructions
- `sexfindr_image.tar` - The Docker image file

## Need Help?

- See `FOR_PROFESSOR_MACOS.md` for detailed step-by-step instructions
- See `TROUBLESHOOTING.md` for common issues
- See `DOCKER_README.md` for advanced Docker usage

---

**Note**: The Docker image works on both Intel and Apple Silicon (M1/M2/M3) Macs!

