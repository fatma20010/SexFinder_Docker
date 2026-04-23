# Quick Fix - Docker Not Running

## The Problem

Error: `failed to connect to the docker API` means **Docker Desktop is not running**.

## Solution

### Step 1: Start Docker Desktop

1. **Open Docker Desktop**:
   - Press `Windows Key`
   - Type "Docker Desktop"
   - Click on "Docker Desktop"

2. **Wait for Docker to Start**:
   - Look for Docker icon in system tray (bottom right)
   - Wait until it shows "Docker is running"
   - This takes 1-2 minutes

### Step 2: Start Web Interface

**Option A: Use the Script (Easiest)**
```powershell
cd C:\Users\msi\SexFindR\web_interface
.\start_web_interface.bat
```

**Option B: Manual Start**
```powershell
cd C:\Users\msi\SexFindR\web_interface
docker-compose up -d
```

### Step 3: Open Browser

Go to: **http://localhost**

## Verify Docker is Running

Check if Docker is working:
```powershell
docker ps
```

If this works (shows container list or empty list), Docker is running!

## If Docker Desktop Won't Start

1. **Check Windows Services**:
   - Press `Win + R`
   - Type `services.msc`
   - Look for "Docker Desktop Service"
   - Right-click → Start

2. **Restart Docker Desktop**:
   - Right-click Docker icon in system tray
   - Click "Restart"

3. **Check System Requirements**:
   - Windows 10/11 64-bit
   - WSL 2 enabled (for newer Docker versions)
   - Virtualization enabled in BIOS

## Quick Commands

```powershell
# Check Docker status
docker ps

# Start web interface
cd C:\Users\msi\SexFindR\web_interface
docker-compose up -d

# Check if containers are running
docker-compose ps

# View logs
docker-compose logs

# Stop interface
docker-compose down
```



