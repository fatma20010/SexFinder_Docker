# Simple Guide - If You Only Have the Docker Image

If you only received the Docker image file (`sexfindr_image.tar`), here's exactly what to do:

## Step 1: Load Docker Image

```bash
# Load the Docker image
docker load -i sexfindr_image.tar

# Verify it loaded
docker images | grep sexfindr
```

## Step 2: Create a Simple Folder

Create a folder anywhere on your Mac (e.g., Desktop):

```bash
mkdir -p ~/Desktop/MyAnalysis/data/bams
cd ~/Desktop/MyAnalysis
```

## Step 3: Put Your BAM Files

**Put your BAM files in the `data/bams/` folder:**

```bash
# Copy your BAM files here
cp /path/to/your/male.bam ~/Desktop/MyAnalysis/data/bams/
cp /path/to/your/female.bam ~/Desktop/MyAnalysis/data/bams/

# Verify they're there
ls -lh ~/Desktop/MyAnalysis/data/bams/
```

**You need:**
- At least 1 male BAM file
- At least 1 female BAM file

## Step 4: Run Step 1

### Easy Way (If you have the script):

```bash
cd ~/Desktop/MyAnalysis

# Copy the script here (if you have it)
# Then run:
chmod +x run_step1_simple_macos.sh
./run_step1_simple_macos.sh
```

### Manual Way (Direct Docker command):

```bash
cd ~/Desktop/MyAnalysis

# Create output folders
mkdir -p Step_1 output

# Run Step 1 (REPLACE the filenames with yours!)
docker run --rm \
  -v "$(pwd)/data:/sexfindr/data" \
  -v "$(pwd)/Step_1:/sexfindr/Step_1" \
  -v "$(pwd)/output:/sexfindr/output" \
  sexfindr:latest \
  bash -c "cd /sexfindr/Step_1 && \
    bash run_difcover.sh \
      /sexfindr/data/bams/YOUR_MALE_FILE.bam \
      /sexfindr/data/bams/YOUR_FEMALE_FILE.bam \
      1.0"
```

**Replace:**
- `YOUR_MALE_FILE.bam` → your actual male BAM filename
- `YOUR_FEMALE_FILE.bam` → your actual female BAM filename
- `1.0` → adjustment coefficient (start with 1.0, adjust if needed)

## Step 5: Check Results

```bash
# View output files
ls -lh ~/Desktop/MyAnalysis/Step_1/

# Look for files ending in .DNAcopyout
ls -lh ~/Desktop/MyAnalysis/Step_1/*.DNAcopyout
```

## Folder Structure Summary

```
MyAnalysis/                    ← You create this folder
│
├── data/
│   └── bams/                  ← PUT YOUR BAM FILES HERE
│       ├── male.bam           ← Your files
│       └── female.bam
│
├── Step_1/                    ← Created automatically (outputs here)
└── output/                    ← Created automatically (results here)
```

## That's It!

The Docker container has all the scripts and tools. You just need:
1. ✅ Docker image loaded
2. ✅ A folder with `data/bams/` subfolder
3. ✅ Your BAM files in that folder
4. ✅ Run the Docker command

## Troubleshooting

**"Docker is not running"**
- Open Docker Desktop app
- Wait until it says "Docker is running"

**"Image not found"**
- Make sure you loaded it: `docker load -i sexfindr_image.tar`
- Check: `docker images | grep sexfindr`

**"BAM file not found"**
- Make sure files are in `data/bams/` folder
- Check the exact filename (case-sensitive on Mac)
- Use: `ls -lh data/bams/` to see files

**Need help?**
- See `MACOS_TESTING_GUIDE.md` for detailed instructions
- See `STEP1_REQUIREMENTS.md` for Step 1 details




