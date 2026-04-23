# Packaging Instructions - What to Send Your Professor

## What to Include in the Package

### Essential Files (Must Include):

1. **Docker Image File**
   - `sexfindr_image.tar` (or `sexfindr_image.tar.gz` if compressed)
   - This is the main file with all the software

2. **Simple Instructions**
   - `README_FIRST.txt` - Start here!
   - `FOR_PROFESSOR.md` - Detailed guide
   - `CHECKLIST.txt` - Simple checklist

3. **Easy-to-Use Scripts**
   - `LOAD_DOCKER.bat` - Load the pipeline
   - `RUN_PIPELINE.bat` - Run the analysis

4. **Help Files**
   - `TROUBLESHOOTING.md` - Solutions to common problems

5. **Pipeline Files** (the folder structure)
   - `Step_0/` folder with sample list templates
   - `data/` folder structure (fastq, bams, vcfs subfolders)
   - `config.sh` - Pre-configured

### Optional Files (Nice to Have):

- `SIMPLE_INSTRUCTIONS.md` - Quick reference
- `DOCKER_README.md` - Technical details (if needed)

## How to Package

### Option 1: ZIP File (Easiest)

1. Create a folder called `SexFindR_For_Professor`
2. Copy these files into it:
   - `sexfindr_image.tar` (or compressed version)
   - `README_FIRST.txt`
   - `FOR_PROFESSOR.md`
   - `CHECKLIST.txt`
   - `LOAD_DOCKER.bat`
   - `RUN_PIPELINE.bat`
   - `TROUBLESHOOTING.md`
   - `Step_0/` folder
   - `data/` folder (empty, just structure)
   - `config.sh`

3. Zip the entire folder
4. Send the ZIP file

### Option 2: USB Drive

1. Put all files on a USB drive
2. Organize in a folder called `SexFindR`
3. Include a note: "Start with README_FIRST.txt"

## File Size Considerations

- Docker image: ~2-5 GB (large!)
- Other files: ~10-50 MB (small)

**Recommendation:**
- Compress the Docker image: `sexfindr_image.tar.gz` (saves ~50% space)
- Or upload to cloud storage and share link
- Or use Docker Hub (see BUILD_DOCKER.md)

## What NOT to Include

- Your personal data files
- Large output files
- Git history (`.git` folder)
- Temporary files

## Testing Before Sending

1. Test on a different computer (if possible)
2. Or test in a clean Docker environment
3. Make sure all scripts work
4. Verify instructions are clear

## Delivery Methods

### Method 1: Cloud Storage (Recommended)
- Upload to Google Drive, Dropbox, or OneDrive
- Share the link
- Professor downloads everything

### Method 2: USB Drive
- Copy everything to USB
- Give to professor
- Easiest if you're nearby

### Method 3: Docker Hub (Best for Updates)
- Push image to Docker Hub
- Share repository link
- Professor pulls with: `docker pull yourusername/sexfindr:latest`
- You can update it easily later

## Checklist Before Sending

- [ ] Docker image built and tested
- [ ] All instruction files included
- [ ] Scripts tested and working
- [ ] Sample list templates included
- [ ] Data folder structure created
- [ ] Instructions are clear and simple
- [ ] File sizes are reasonable
- [ ] Everything is in one package

## Quick Package Script

Create a folder and copy everything:

```powershell
# Create package folder
New-Item -ItemType Directory -Path "SexFindR_Package"

# Copy essential files
Copy-Item "sexfindr_image.tar*" -Destination "SexFindR_Package\"
Copy-Item "README_FIRST.txt" -Destination "SexFindR_Package\"
Copy-Item "FOR_PROFESSOR.md" -Destination "SexFindR_Package\"
Copy-Item "CHECKLIST.txt" -Destination "SexFindR_Package\"
Copy-Item "LOAD_DOCKER.bat" -Destination "SexFindR_Package\"
Copy-Item "RUN_PIPELINE.bat" -Destination "SexFindR_Package\"
Copy-Item "TROUBLESHOOTING.md" -Destination "SexFindR_Package\"
Copy-Item "Step_0" -Recurse -Destination "SexFindR_Package\"
Copy-Item "data" -Recurse -Destination "SexFindR_Package\"
Copy-Item "config.sh" -Destination "SexFindR_Package\"

# Create ZIP
Compress-Archive -Path "SexFindR_Package\*" -DestinationPath "SexFindR_For_Professor.zip"
```

## Final Notes

- Make it as simple as possible
- Include clear instructions
- Test everything first
- Be available for questions (at least initially)

Good luck! 🎉





