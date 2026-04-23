# Docker Image Successfully Built! ✅

The SexFindR Docker image has been successfully built and tested. Your professor can now use this image to run the pipeline.

## Image Details

- **Image Name**: `sexfindr:latest`
- **Image ID**: `d3b997e654b9`
- **Size**: ~3.34 GB (disk usage), ~992 MB (compressed)
- **Status**: ✅ All tools tested and working

## What's Included

✅ **R 4.1.2** with packages:
   - tidyverse
   - patchwork
   - ggpubr
   - ggthemes

✅ **Bioinformatics Tools**:
   - Bowtie2 v2.5.2
   - SAMtools v1.19
   - VCFtools v0.1.16

✅ **Pipeline Components**:
   - All SexFindR scripts
   - DifCover (cloned from GitHub)
   - Pre-configured config.sh with Docker paths
   - Reference genome paths configured (if included)

## How to Share with Your Professor

### Option 1: Save as Tar File (Recommended)

```powershell
cd C:\Users\msi\SexFindR
docker save -o sexfindr_image.tar sexfindr:latest
```

This creates a file `sexfindr_image.tar` that you can:
- Upload to cloud storage (Google Drive, Dropbox, etc.)
- Share via USB drive
- Email if file size allows (may need to compress first)

**Note**: The tar file will be large (~3-4 GB). Consider compressing it with 7-Zip or similar.

### Option 2: Push to Docker Hub

If you have a Docker Hub account:

```powershell
# Tag the image
docker tag sexfindr:latest yourusername/sexfindr:latest

# Push to Docker Hub
docker push yourusername/sexfindr:latest
```

Then your professor can pull it with:
```bash
docker pull yourusername/sexfindr:latest
```

### Option 3: Share Dockerfile Only

Share the entire repository (excluding large data files), and your professor can build it:
```bash
docker build -t sexfindr:latest .
```

## For Your Professor: How to Use

### Step 1: Load the Image (if received as tar file)

```bash
docker load -i sexfindr_image.tar
```

### Step 2: Verify the Image

```bash
docker images sexfindr:latest
```

### Step 3: Run the Container

**Using Docker Compose (Easiest)**:
```bash
docker-compose up -d
docker-compose exec sexfindr bash
```

**Or using Docker directly**:
```bash
docker run -it --rm \
  -v $(pwd)/data:/sexfindr/data \
  -v $(pwd)/output:/sexfindr/output \
  -v $(pwd)/Step_0:/sexfindr/Step_0 \
  sexfindr:latest \
  bash
```

### Step 4: Inside the Container

```bash
# Load configuration
source /sexfindr/config.sh

# Verify tools
Rscript --version
bowtie2 --version
samtools --version

# Run pipeline steps as needed
cd /sexfindr/Step_1
bash run_difcover.sh <male_bam> <female_bam> <adjustment_coefficient>
```

## Quick Test

To verify everything works, your professor can run:

```bash
docker run --rm sexfindr:latest bash -c "Rscript --version && bowtie2 --version && samtools --version && echo 'All tools working!'"
```

## Important Notes

1. **Data Mounting**: The professor needs to mount their data directories when running the container
2. **Config File**: The config.sh is pre-configured for Docker paths, but can be overridden by mounting a custom config.sh
3. **Reference Genome**: If the reference genome is included in the image, it's at `/sexfindr/ncbi_dataset/...`
4. **DifCover**: Already cloned and available at `/sexfindr/DifCover/dif_cover_scripts`

## Troubleshooting

If the professor encounters issues:
1. Make sure Docker Desktop is running
2. Check that data directories are properly mounted
3. Verify sample list files are in `Step_0/` directory
4. See `DOCKER_README.md` and `TROUBLESHOOTING.md` for more help

## Next Steps

1. ✅ Image built successfully
2. ✅ All tools tested and working
3. 📦 Save the image (choose one of the options above)
4. 📧 Share with your professor along with `DOCKER_README.md` and `FOR_PROFESSOR.md`

---

**Build Date**: March 9, 2026
**Status**: Ready for use! 🎉

