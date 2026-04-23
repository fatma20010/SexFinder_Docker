# SexFindR Pipeline - Simple Guide for macOS Users

## Welcome! 👋

This guide will help you run the SexFindR pipeline on macOS easily, even if you're not familiar with programming.

## What You Need (3 Things)

1. **Docker Desktop for Mac** - A program that runs the pipeline
2. **Your data files** - Your sequencing data (FASTQ, BAM, or VCF files)
3. **This folder** - The SexFindR pipeline files

---

## Part 1: Install Docker Desktop (One-Time Setup)

### Step 1: Download Docker Desktop
- Go to: https://www.docker.com/products/docker-desktop
- Click "Download for Mac"
- Choose the version for your Mac (Intel or Apple Silicon/M1/M2)
- Save the file

### Step 2: Install Docker Desktop
- Double-click the downloaded `.dmg` file
- Drag Docker to your Applications folder
- Open Docker from Applications
- Follow the setup wizard
- Enter your password when prompted

### Step 3: Start Docker Desktop
- Open Docker Desktop from Applications
- Wait until you see "Docker Desktop is running" (green icon in menu bar)
- The first time may take a few minutes to start

**✅ Done! You only need to do this once.**

---

## Part 2: Load the Pipeline (One-Time Setup)

### Step 1: Get the Docker Image
- You should have received a file called `sexfindr_image.tar` or `sexfindr_image.tar.gz`
- Put it in this SexFindR folder

### Step 2: Open Terminal
- Press `Cmd + Space` to open Spotlight
- Type "Terminal" and press Enter

### Step 3: Navigate to the SexFindR Folder
In Terminal, type:
```bash
cd ~/Downloads/SexFindR
```
(Replace `~/Downloads/SexFindR` with the actual path where you put the folder)

### Step 4: Make Scripts Executable
```bash
chmod +x load_docker.sh run_pipeline.sh
```

### Step 5: Load the Image
```bash
./load_docker.sh
```
- Wait for it to finish (may take 5-10 minutes)
- When it says "Success!", you're ready!

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
2. Open `male_samples.txt` in TextEdit
3. Delete everything in the file
4. Type your male sample names, one per line (just the name, no file extension)
   - Example:
     ```
     male_001
     male_002
     male_003
     ```
5. Save the file (Cmd+S)
6. Do the same for `female_samples.txt` with your female sample names

**✅ Done! Your data is ready.**

---

## Part 4: Run the Pipeline

### Step 1: Make Sure Docker is Running
- Look at the top right of your screen (menu bar)
- You should see a Docker icon (whale)
- If it's running, you'll see "Docker Desktop is running"
- If not, open Docker Desktop from Applications

### Step 2: Open Terminal
- Press `Cmd + Space`
- Type "Terminal" and press Enter

### Step 3: Navigate to SexFindR Folder
```bash
cd ~/Downloads/SexFindR
```
(Replace with your actual path)

### Step 4: Run the Pipeline
```bash
./run_pipeline.sh
```
- A window will show progress
- **Important:** Don't close this window! Let it run.
- This may take a long time (hours or even days for large datasets)

### Step 5: Get Your Results
- When it's done, open the `output` folder
- Your results will be there!

**✅ Done! You have your results.**

---

## Quick Reference

| What You Want To Do | What To Type |
|---------------------|--------------|
| Load the pipeline (first time) | `./load_docker.sh` |
| Run your analysis | `./run_pipeline.sh` |
| Check for problems | See `TROUBLESHOOTING.md` |

---

## Common Questions

**Q: How long does it take?**  
A: It depends on your data size. Small datasets: minutes. Large datasets: hours or days.

**Q: Can I close my computer?**  
A: No, keep your computer on and awake while it's running. You can close the lid if you disable sleep mode.

**Q: What if something goes wrong?**  
A: Check `TROUBLESHOOTING.md` for solutions.

**Q: Do I need internet?**  
A: Only for the first-time setup (downloading Docker). After that, no internet needed.

**Q: I'm on Apple Silicon (M1/M2/M3). Will it work?**  
A: Yes! Docker Desktop supports Apple Silicon. Just make sure you download the correct version.

---

## Alternative: Using Docker Compose (Easier)

If you prefer, you can use Docker Compose:

1. **Start the container:**
   ```bash
   docker-compose up -d
   ```

2. **Enter the container:**
   ```bash
   docker-compose exec sexfindr bash
   ```

3. **Run your analysis** inside the container

4. **Stop the container:**
   ```bash
   docker-compose down
   ```

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

1. **Add your data** → Copy files to `data/fastq/` (or bams/vcfs)
2. **Add sample names** → Edit `Step_0/male_samples.txt` and `female_samples.txt`
3. **Run** → Open Terminal, navigate to folder, type `./run_pipeline.sh`

That's it! 🎉

