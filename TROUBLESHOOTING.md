# Troubleshooting Guide - Simple Solutions

## Problem: "Docker is not running"

**Solution:**
1. Look for the Docker icon in your system tray (bottom right)
2. If you see a red icon, click it and select "Start Docker Desktop"
3. Wait until the icon turns green
4. Try again

## Problem: "Docker image not found"

**Solution:**
1. Make sure you ran `LOAD_DOCKER.bat` first
2. Check that `sexfindr_image.tar` file exists in the folder
3. If not, ask for the Docker image file

## Problem: "No data files found"

**Solution:**
1. Make sure your data files are in the correct folder:
   - FASTQ files → `data\fastq\`
   - BAM files → `data\bams\`
   - VCF files → `data\vcfs\`
2. Check that file names match your sample list

## Problem: "Sample list is empty"

**Solution:**
1. Open `Step_0\male_samples.txt` in Notepad
2. Delete all the example text (lines starting with #)
3. Type your sample names, one per line
4. Save the file
5. Do the same for `Step_0\female_samples.txt`

## Problem: Pipeline takes too long

**This is normal!** 
- Mapping FASTQ files can take hours or even days
- It depends on:
  - How many samples you have
  - How large your files are
  - Your computer speed
- Just let it run - you can check progress later

## Problem: "Permission denied" or "Access denied"

**Solution:**
1. Make sure Docker Desktop is running as Administrator
2. Right-click Docker Desktop → Run as Administrator
3. Try again

## Problem: Not enough disk space

**Solution:**
- Docker needs at least 20 GB free space
- Delete old Docker images: Docker Desktop → Settings → Resources → Clean up

## Problem: Still having issues?

**Contact support with:**
1. What step you're on
2. The exact error message
3. Screenshot if possible


