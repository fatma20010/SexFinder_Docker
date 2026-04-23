# Docker Not Found - Installation Required

## Docker is Not Installed

To build the Docker image, you need Docker Desktop installed first.

## Quick Installation Guide

### Step 1: Download Docker Desktop
1. Go to: https://www.docker.com/products/docker-desktop
2. Click "Download for Windows"
3. Save the installer file

### Step 2: Install Docker Desktop
1. Double-click the downloaded installer
2. Follow the installation wizard:
   - Accept the license
   - Choose installation location (default is fine)
   - Enable "Use WSL 2 instead of Hyper-V" (recommended)
   - Click "Install"
3. When installation completes, click "Close and restart"

### Step 3: Start Docker Desktop
1. After restart, open Docker Desktop from Start menu
2. Accept the terms of service
3. Wait until you see "Docker Desktop is running" (green icon)
4. This may take a few minutes the first time

### Step 4: Verify Installation
Open PowerShell and run:
```powershell
docker --version
```

You should see something like: `Docker version 24.x.x`

## After Docker is Installed

Once Docker Desktop is running, you can build the image:

```powershell
cd C:\Users\msi\SexFindR
powershell -ExecutionPolicy Bypass -File build_docker.ps1
```

Or manually:
```powershell
docker build -t sexfindr:latest .
docker save -o sexfindr_image.tar sexfindr:latest
```

## System Requirements

- Windows 10 64-bit: Pro, Enterprise, or Education (Build 15063 or later)
- OR Windows 11 64-bit
- WSL 2 feature enabled (Docker will help you enable this)
- Virtualization enabled in BIOS
- At least 4GB RAM (8GB+ recommended)
- At least 20GB free disk space

## Troubleshooting

### "WSL 2 installation is incomplete"
- Docker Desktop will provide a link to install WSL 2
- Follow the instructions to install WSL 2
- Restart your computer

### "Virtualization is not enabled"
- Restart your computer
- Enter BIOS/UEFI settings (usually F2, F10, or Del during startup)
- Enable "Virtualization Technology" or "Intel VT-x" or "AMD-V"
- Save and exit

### Docker Desktop won't start
- Make sure Windows is up to date
- Check that virtualization is enabled in BIOS
- Try running Docker Desktop as Administrator

## Need Help?

- Docker Desktop documentation: https://docs.docker.com/desktop/
- Docker Desktop support: https://docs.docker.com/desktop/troubleshoot/





