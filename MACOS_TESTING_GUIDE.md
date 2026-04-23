# macOS Testing Guide - SexFindR Pipeline

This guide will help you test the SexFindR pipeline on a macOS laptop with your data.

## ⚡ Quick Start Options

### Option 1: If You Only Have Docker Image

See the section below for Docker-only setup.

### Option 2: If You Only Have run_pipeline.sh and run_all_steps.sh

**See `DATA_ORGANIZATION_FOR_SCRIPTS.md` for detailed instructions!**

Quick version:
1. Create folder structure: `mkdir -p data/bams Step_0 Step_1 Step_2 Step_3 output`
2. Put BAM files in: `data/bams/`
3. Create `config.sh` (minimal version - see guide)
4. Create sample lists in `Step_0/` (optional for run_all_steps.sh)
5. Run: `./run_all_steps.sh`

Or use the setup script:
```bash
chmod +x setup_project_folder.sh
./setup_project_folder.sh
```

---

## ⚡ Quick Start (If You Only Have Docker Image)

**If the professor only gave you the Docker image file (`sexfindr_image.tar`), here's the fastest way to test Step 1:**

### 1. Load Docker Image
```bash
docker load -i sexfindr_image.tar
```

### 2. Create a Simple Folder Structure
```bash
# Create a project folder anywhere (e.g., Desktop)
mkdir -p ~/Desktop/MySexFindR/data/bams
cd ~/Desktop/MySexFindR
```

### 3. Put Your BAM Files
```bash
# Copy your BAM files here
cp /path/to/your/male.bam ~/Desktop/MySexFindR/data/bams/
cp /path/to/your/female.bam ~/Desktop/MySexFindR/data/bams/
```

### 4. Run Step 1

**Option A: Use the Simple Script (Easiest)**

If you have the `run_step1_simple_macos.sh` script:
```bash
cd ~/Desktop/MySexFindR
chmod +x run_step1_simple_macos.sh
./run_step1_simple_macos.sh
```

The script will:
- Check Docker is running
- Create folder structure
- List your BAM files
- Ask which files to use
- Run Step 1 automatically

**Option B: Run Directly with Docker**

```bash
cd ~/Desktop/MySexFindR

# Run Step 1 (replace filenames with yours)
docker run --rm \
  -v "$(pwd)/data:/sexfindr/data" \
  -v "$(pwd)/Step_1:/sexfindr/Step_1" \
  -v "$(pwd)/output:/sexfindr/output" \
  sexfindr:latest \
  bash -c "cd /sexfindr/Step_1 && \
    bash run_difcover.sh \
      /sexfindr/data/bams/MALE_FILENAME.bam \
      /sexfindr/data/bams/FEMALE_FILENAME.bam \
      1.0"
```

**Replace:**
- `MALE_FILENAME.bam` with your actual male BAM filename
- `FEMALE_FILENAME.bam` with your actual female BAM filename
- `1.0` with your adjustment coefficient (start with 1.0 if unsure)

**That's it!** Results will be in the `Step_1/` folder.

---

## Detailed Guide (Full Instructions)

## Step 1: Transfer Files to macOS

### Option A: Transfer Docker Image and Project Folder

1. **Copy the Docker image file:**
   - From Windows: `sexfindr_image.tar`
   - Transfer to macOS (via USB, network share, or cloud storage)

2. **Copy the entire SexFindR project folder:**
   - Copy the entire `SexFindR` folder to your macOS laptop
   - Keep the same folder structure

### Option B: Save Docker Image from Windows

On your Windows machine, save the Docker image:

```powershell
docker save sexfindr:latest -o sexfindr_image.tar
```

Then transfer `sexfindr_image.tar` to macOS.

## Step 2: Setup on macOS

### 1. Install Docker Desktop for Mac

1. Download Docker Desktop from: https://www.docker.com/products/docker-desktop
2. Install it (drag to Applications folder)
3. Open Docker Desktop and wait until it says "Docker is running"

### 2. Load the Docker Image

Open Terminal on macOS and navigate to where you saved the Docker image:

```bash
# Navigate to the folder containing sexfindr_image.tar
cd ~/Downloads  # or wherever you saved it

# Load the Docker image
docker load -i sexfindr_image.tar

# Verify it loaded
docker images | grep sexfindr
```

You should see `sexfindr:latest` in the list.

### 3. Navigate to Your Project Folder

```bash
cd /path/to/your/SexFindR
```

## Step 3: Create Project Folder Structure

**IMPORTANT:** If you only have the Docker image (not the full project folder), you need to create the folder structure yourself.

### Create the Required Folders

On your macOS laptop, create a project folder anywhere you want (e.g., Desktop, Documents):

```bash
# Create a project folder (choose any location)
mkdir -p ~/Desktop/SexFindR_Project
cd ~/Desktop/SexFindR_Project

# Create the required folder structure
mkdir -p data/bams      # For BAM files (needed for Step 1)
mkdir -p data/fastq     # For FASTQ files (if you have them)
mkdir -p data/vcfs      # For VCF files (if you have them)
mkdir -p Step_1         # For Step 1 scripts and outputs
mkdir -p output         # For final results
```

### Minimal Structure for Step 1

For Step 1 testing, you only need:

```
SexFindR_Project/
├── data/
│   └── bams/          ← PUT YOUR BAM FILES HERE
├── Step_1/            ← Will be created automatically by Docker
└── output/            ← Results will appear here
```

**That's it!** The Docker container has all the scripts inside. You just need:
1. A folder to mount your data
2. Your BAM files in `data/bams/`

### Visual Example

```
~/Desktop/SexFindR_Project/          ← Your project folder (create this)
│
├── data/
│   └── bams/                        ← PUT YOUR BAM FILES HERE
│       ├── male_sample.bam          ← Your male BAM file
│       └── female_sample.bam         ← Your female BAM file
│
├── Step_1/                          ← Created automatically (outputs go here)
└── output/                          ← Created automatically (final results)
```

**Key Point:** You only need to create the `data/bams/` folder and put your BAM files there. The Docker container will handle everything else!

## Step 4: Put Your Data Files

### Where to Put Your BAM Files

**Put your BAM files directly in: `data/bams/`**

For example, if your project is at `~/Desktop/SexFindR_Project`:

```bash
# Copy your BAM files to the bams folder
cp /path/to/your/male_sample.bam ~/Desktop/SexFindR_Project/data/bams/
cp /path/to/your/female_sample.bam ~/Desktop/SexFindR_Project/data/bams/

# Verify they're there
ls -lh ~/Desktop/SexFindR_Project/data/bams/
```

### Check Your Data Structure

```bash
# Navigate to your project folder
cd ~/Desktop/SexFindR_Project  # or wherever you created it

# Check what data you have
ls -lh data/bams/     # Check for BAM files
ls -lh data/fastq/     # Check for FASTQ files (if you have them)
ls -lh data/vcfs/     # Check for VCF files (if you have them)
```

### For Step 1 Testing (DifCover), you need:

1. **At least 2 BAM files:**
   - 1 male BAM file
   - 1 female BAM file
   
   Place them in: `data/bams/`

2. **Update sample lists** (if needed):
   ```bash
   # Edit male samples
   nano Step_0/male_samples.txt
   # Add your male sample IDs (one per line, no comments)
   
   # Edit female samples
   nano Step_0/female_samples.txt
   # Add your female sample IDs (one per line, no comments)
   ```

## Step 5: Test Step 1 - Quick Test Script

### Option A: Use the Provided Script (If You Have It)

If you have the `test_step1_macos.sh` script, just run it:

```bash
# Create a test script
cat > test_step1_macos.sh << 'EOF'
#!/bin/bash

echo "=========================================="
echo "SexFindR Step 1 - macOS Test"
echo "=========================================="
echo ""

# Check if Docker is running
if ! docker ps >/dev/null 2>&1; then
    echo "ERROR: Docker is not running!"
    echo "Please open Docker Desktop and wait until it says 'Docker is running'"
    exit 1
fi

# Check if image exists
if ! docker images sexfindr:latest | grep -q sexfindr; then
    echo "ERROR: Docker image not found!"
    echo "Please run: docker load -i sexfindr_image.tar"
    exit 1
fi

# Get current directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check for BAM files
BAM_COUNT=$(find data/bams -name "*.bam" 2>/dev/null | wc -l | tr -d ' ')

if [ "$BAM_COUNT" -lt 2 ]; then
    echo "ERROR: Need at least 2 BAM files in data/bams/"
    echo "Found: $BAM_COUNT BAM file(s)"
    echo ""
    echo "Please add:"
    echo "  - 1 male BAM file"
    echo "  - 1 female BAM file"
    exit 1
fi

echo "Found $BAM_COUNT BAM file(s)"
echo ""

# List BAM files
echo "BAM files found:"
find data/bams -name "*.bam" | while read bam; do
    echo "  - $(basename $bam)"
done
echo ""

# Ask user to specify which files to use
echo "Please specify:"
read -p "Male BAM filename (from data/bams/): " MALE_BAM
read -p "Female BAM filename (from data/bams/): " FEMALE_BAM
read -p "Adjustment Coefficient (AC) [default: 1.0]: " AC
AC=${AC:-1.0}

# Check files exist
if [ ! -f "data/bams/$MALE_BAM" ]; then
    echo "ERROR: Male BAM file not found: data/bams/$MALE_BAM"
    exit 1
fi

if [ ! -f "data/bams/$FEMALE_BAM" ]; then
    echo "ERROR: Female BAM file not found: data/bams/$FEMALE_BAM"
    exit 1
fi

echo ""
echo "Running Step 1 DifCover analysis..."
echo "  Male BAM: $MALE_BAM"
echo "  Female BAM: $FEMALE_BAM"
echo "  AC: $AC"
echo ""

# Create output directory
mkdir -p output

# Run Step 1
docker run --rm \
    -v "$SCRIPT_DIR/data:/sexfindr/data" \
    -v "$SCRIPT_DIR/Step_1:/sexfindr/Step_1" \
    -v "$SCRIPT_DIR/output:/sexfindr/output" \
    sexfindr:latest \
    bash -c "cd /sexfindr/Step_1 && \
        bash run_difcover.sh \
            /sexfindr/data/bams/$MALE_BAM \
            /sexfindr/data/bams/$FEMALE_BAM \
            $AC"

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "Step 1 completed successfully!"
    echo "=========================================="
    echo ""
    echo "Output files are in: Step_1/"
    echo "Results are in: output/"
    echo ""
else
    echo ""
    echo "ERROR: Step 1 failed!"
    echo "Check the error messages above."
    exit 1
fi
EOF

# Make it executable
chmod +x test_step1_macos.sh
```

## Step 5: Run the Test

### Quick Test (Interactive)

```bash
./test_step1_macos.sh
```

The script will:
1. Check Docker is running
2. Check the image is loaded
3. List your BAM files
4. Ask you which files to use
5. Run Step 1

### Direct Test (Non-Interactive)

If you know your file names, run directly:

```bash
# Replace with your actual file names and AC value
docker run --rm \
    -v "$(pwd)/data:/sexfindr/data" \
    -v "$(pwd)/Step_1:/sexfindr/Step_1" \
    -v "$(pwd)/output:/sexfindr/output" \
    sexfindr:latest \
    bash -c "cd /sexfindr/Step_1 && \
        bash run_difcover.sh \
            /sexfindr/data/bams/MALE_BAM.bam \
            /sexfindr/data/bams/FEMALE_BAM.bam \
            1.0"
```

## Step 6: Calculate Adjustment Coefficient (Optional but Recommended)

Before running, you can calculate the proper AC value:

```bash
# Create a script to calculate modal depths
cat > calculate_AC_macos.sh << 'EOF'
#!/bin/bash

echo "Calculating modal depths for BAM files..."
echo ""

for bam in data/bams/*.bam; do
    if [ -f "$bam" ]; then
        echo "Processing: $(basename $bam)"
        docker run --rm \
            -v "$(pwd)/data:/sexfindr/data" \
            sexfindr:latest \
            bash -c "cd /sexfindr/data/bams && \
                samtools stats $(basename $bam) > temp_stats && \
                number=\$(grep ^COV temp_stats | cut -f 2- | awk -v max=0 '{if(\$3>max){want=\$2; max=\$3}}END{print want}') && \
                echo \"  Modal depth: \$number\" && \
                rm temp_stats"
    fi
done

echo ""
echo "AC = (Female modal depth) / (Male modal depth)"
EOF

chmod +x calculate_AC_macos.sh
./calculate_AC_macos.sh
```

## Step 7: Verify Results

After Step 1 completes, check the output:

```bash
# List output files
ls -lh Step_1/*.DNAcopyout
ls -lh Step_1/*.unionbedcv

# Check output directory
ls -lh output/
```

Expected output files:
- `sample1_sample2.unionbedcv`
- `sample1_sample2.ratio_per_w_CC0_a10_A219_b10_B240_v1000_l500`
- `sample1_sample2.ratio_per_w_CC0_a10_A219_b10_B240_v1000_l500.log2adj_1.DNAcopyout`

## Troubleshooting on macOS

### 1. Docker Permission Issues

If you get permission errors:

```bash
# Make sure Docker Desktop is running
# Check Docker status
docker ps
```

### 2. Path Issues

macOS uses forward slashes. Make sure paths are correct:

```bash
# Use absolute paths if relative paths don't work
docker run --rm \
    -v "/Users/yourusername/path/to/SexFindR/data:/sexfindr/data" \
    ...
```

### 3. File Not Found Errors

Make sure your BAM files are actually in `data/bams/`:

```bash
# Check files
ls -la data/bams/
```

### 4. Docker Image Not Found

If the image isn't found:

```bash
# List all images
docker images

# If sexfindr:latest is missing, reload it
docker load -i sexfindr_image.tar
```

### 5. Script Permission Denied

Make scripts executable:

```bash
chmod +x test_step1_macos.sh
chmod +x calculate_AC_macos.sh
```

## Quick Reference Commands

```bash
# Check Docker is running
docker ps

# Check image is loaded
docker images | grep sexfindr

# List BAM files
ls -lh data/bams/

# Run Step 1 (replace file names)
docker run --rm \
    -v "$(pwd)/data:/sexfindr/data" \
    -v "$(pwd)/Step_1:/sexfindr/Step_1" \
    -v "$(pwd)/output:/sexfindr/output" \
    sexfindr:latest \
    bash -c "cd /sexfindr/Step_1 && bash run_difcover.sh /sexfindr/data/bams/MALE.bam /sexfindr/data/bams/FEMALE.bam 1.0"

# Check results
ls -lh Step_1/*.DNAcopyout
```

## Next Steps

After Step 1 completes successfully:
1. Review the output files in `Step_1/`
2. Run the R visualization script (if needed)
3. Proceed to Step 2 if you have VCF files

## Need Help?

- Check `STEP1_REQUIREMENTS.md` for detailed Step 1 requirements
- Check `SETUP.md` for full pipeline documentation
- Check `TROUBLESHOOTING.md` for common issues

