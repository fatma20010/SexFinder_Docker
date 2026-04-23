# Quick Transfer Guide - Windows to macOS

## What to Transfer

1. **Docker Image File:**
   - `sexfindr_image.tar` (the Docker image)

2. **Entire SexFindR Folder:**
   - Copy the whole `SexFindR` folder to your macOS laptop
   - This includes all scripts, configs, and your data

## Transfer Methods

### Option 1: USB Drive
1. Copy `sexfindr_image.tar` and the `SexFindR` folder to USB
2. Transfer to macOS
3. Copy to your desired location on macOS

### Option 2: Network Share
1. Share the folder from Windows
2. Access from macOS and copy files

### Option 3: Cloud Storage (Dropbox, Google Drive, etc.)
1. Upload `sexfindr_image.tar` and `SexFindR` folder
2. Download on macOS

## On macOS - Quick Setup

### 1. Install Docker Desktop
- Download: https://www.docker.com/products/docker-desktop
- Install and open Docker Desktop
- Wait for "Docker is running"

### 2. Load Docker Image
```bash
cd ~/Downloads  # or wherever you saved the image
docker load -i sexfindr_image.tar
```

### 3. Navigate to Project
```bash
cd /path/to/your/SexFindR
```

### 4. Make Scripts Executable
```bash
chmod +x test_step1_macos.sh
chmod +x calculate_AC_macos.sh
```

### 5. Test Step 1
```bash
./test_step1_macos.sh
```

## Quick Test Checklist

- [ ] Docker Desktop installed and running
- [ ] Docker image loaded (`docker images | grep sexfindr`)
- [ ] SexFindR folder copied to macOS
- [ ] BAM files in `data/bams/` (at least 2 files)
- [ ] Scripts are executable
- [ ] Run `./test_step1_macos.sh`

## Need More Help?

See `MACOS_TESTING_GUIDE.md` for detailed instructions.




