# Quick Start Guide - SexFindR Web Interface

## 🚀 Get Started in 3 Steps

### Step 1: Load Docker Image (if not already done)

```bash
docker load -i ../sexfindr_image.tar
```

### Step 2: Start the Web Interface

**On Windows:**
```bash
start.bat
```

**On macOS/Linux:**
```bash
chmod +x start.sh
./start.sh
```

**Or manually:**
```bash
docker-compose up -d
```

### Step 3: Open Your Browser

Navigate to: **http://localhost**

That's it! You're ready to use the SexFindR pipeline through the web interface.

## 📋 What You Can Do

1. **Upload Files**: Drag and drop your BAM, FASTQ, or VCF files
2. **Configure**: Set parameters like adjustment coefficient
3. **Run**: Click "Start Pipeline" and watch progress in real-time
4. **Download**: Get your results when complete

## 🛑 To Stop

```bash
docker-compose down
```

## ❓ Troubleshooting

**Can't access http://localhost?**
- Make sure Docker Compose started successfully
- Check: `docker-compose ps`
- View logs: `docker-compose logs`

**Pipeline not running?**
- Check Docker is running: `docker ps`
- Verify image exists: `docker images | grep sexfindr`
- Check backend logs: `docker-compose logs backend`

**File upload fails?**
- Check file size (max 10GB)
- Verify file extension is allowed (.bam, .fastq, .fq, .vcf, .gz)

## 📖 More Information

See `README.md` for detailed documentation.




