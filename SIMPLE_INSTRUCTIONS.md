# Simple Instructions for Professor

## What You Need
1. Docker Desktop installed (download from: https://www.docker.com/products/docker-desktop)
2. Your sequencing data files (FASTQ, BAM, or VCF files)
3. This SexFindR folder

## Step-by-Step (Just 5 Steps!)

### Step 1: Install Docker (if not already installed)
- Download Docker Desktop from: https://www.docker.com/products/docker-desktop
- Install it (just click Next, Next, Next)
- Open Docker Desktop and wait until it says "Docker is running"

### Step 2: Load the Docker Image
- Double-click `LOAD_DOCKER.bat` (or run it from command prompt)
- Wait until it says "Done!"

### Step 3: Add Your Data Files
- Open the `data` folder
- Copy your FASTQ files into `data/fastq` folder
  - OR copy your BAM files into `data/bams` folder
  - OR copy your VCF files into `data/vcfs` folder

### Step 4: Add Your Sample Names
- Open `Step_0/male_samples.txt` in Notepad
- Delete the example text
- Type your male sample names (one per line)
- Save the file
- Do the same for `Step_0/female_samples.txt` with female samples

### Step 5: Run the Pipeline
- Double-click `RUN_PIPELINE.bat`
- Wait for it to finish (this may take a while)
- Results will be in the `output` folder

## That's It! 🎉

Your results will be in the `output` folder when it's done.

## Need Help?
- Check `TROUBLESHOOTING.md` for common issues
- Make sure Docker Desktop is running (green icon in system tray)





