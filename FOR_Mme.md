# SexFindR Pipeline - Simple Guide for Non-Technical Users

## Welcome! 👋

This guide will help you run the SexFindR pipeline easily, even if you're not familiar with programming.

## What You Need (3 Things)

1. **Docker Desktop** - A program that runs the pipeline
2. **Your data files** - Your sequencing data (FASTQ, BAM, or VCF files)
3. **This folder** - The SexFindR pipeline files

---

## Part 1: Install Docker Desktop (One-Time Setup)

### Step 1: Download Docker Desktop
- Go to: https://www.docker.com/products/docker-desktop
- Click "Download for Windows"
- Save the file

### Step 2: Install Docker Desktop
- Double-click the downloaded file
- Click "Next" through all the steps
- When asked, click "Restart" to restart your computer

### Step 3: Start Docker Desktop
- After restart, find Docker Desktop in your Start menu
- Open it
- Wait until you see "Docker Desktop is running" (green icon)

**✅ Done! You only need to do this once.**

---

## Part 2: Load the Pipeline (One-Time Setup)

### Step 1: Get the Docker Image
- You should have received a file called `sexfindr_image.tar` or `sexfindr_image.tar.gz`
- Put it in this SexFindR folder

### Step 2: Load the Image
- Double-click `LOAD_DOCKER.bat`
- Wait for it to finish (may take 5-10 minutes)
- When it says "Done!", you're ready!

**✅ Done! You only need to do this once.**

---

## Part 3: Add Your Data (Every Time You Run)

### Step 1: Prepare Your Data Files
You need to know what type of files you have:

- **FASTQ files** (usually end in .fastq or .fq) → Go to Step 2A
- **BAM files** (usually end in .bam) → Go to Step 2B  
- **VCF files** (usually end in .vcf) → Go to Step 2C

### Step 2A: If You Have FASTQ Files
1. Open the `data` folder
2. Open the `fastq` folder inside it
3. Copy all your FASTQ files into this `fastq` folder
4. Make sure file names look like: `sample_name_R1.fastq` and `sample_name_R2.fastq`

### Step 2B: If You Have BAM Files
1. Open the `data` folder
2. Open the `bams` folder inside it
3. Copy all your BAM files into this `bams` folder

### Step 2C: If You Have VCF Files
1. Open the `data` folder
2. Open the `vcfs` folder inside it
3. Copy all your VCF files into this `vcfs` folder

### Step 3: Add Sample Names
1. Open `Step_0` folder
2. Open `male_samples.txt` in Notepad
3. Delete everything in the file
4. Type your male sample names, one per line (just the name, no file extension)
   - Example:
     ```
     male_001
     male_002
     male_003
     ```
5. Save the file (Ctrl+S)
6. Do the same for `female_samples.txt` with your female sample names

**✅ Done! Your data is ready.**

---

## Part 4: Run the Pipeline

### Step 1: Make Sure Docker is Running
- Look at the bottom right of your screen (system tray)
- You should see a Docker icon (whale)
- If it's green, you're good!
- If it's red or missing, open Docker Desktop

### Step 2: Run the Pipeline
- Double-click `RUN_PIPELINE.bat`
- A window will open showing progress
- **Important:** Don't close this window! Let it run.
- This may take a long time (hours or even days for large datasets)

### Step 3: Get Your Results
- When it's done, open the `output` folder
- Your results will be there!

**✅ Done! You have your results.**

---

## Quick Reference

| What You Want To Do | What To Click |
|---------------------|---------------|
| Load the pipeline (first time) | `LOAD_DOCKER.bat` |
| Run your analysis | `RUN_PIPELINE.bat` |
| Check for problems | See `TROUBLESHOOTING.md` |

---

## Common Questions

**Q: How long does it take?**  
A: It depends on your data size. Small datasets: minutes. Large datasets: hours or days.

**Q: Can I close my computer?**  
A: No, keep your computer on and awake while it's running.

**Q: What if something goes wrong?**  
A: Check `TROUBLESHOOTING.md` for solutions.

**Q: Do I need internet?**  
A: Only for the first-time setup (downloading Docker). After that, no internet needed.

---

## Need More Help?

1. Check `TROUBLESHOOTING.md` first
2. Make sure Docker Desktop is running (green icon)
3. Contact support with:
   - What you were trying to do
   - The error message (if any)
   - A screenshot if possible

---

## Summary: The 3 Steps Every Time

1. **Add your data** → Copy files to `data\fastq\` (or bams/vcfs)
2. **Add sample names** → Edit `Step_0\male_samples.txt` and `female_samples.txt`
3. **Run** → Double-click `RUN_PIPELINE.bat`

That's it! 🎉


