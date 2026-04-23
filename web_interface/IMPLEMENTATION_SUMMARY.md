# Step 0 Implementation Summary

## ✅ What I've Implemented

### 1. Created Step 0 Mapping Script
- **File**: `web_interface/Step_0/run_step0_mapping.sh`
- **Features**:
  - Reads sample lists (male_samples.txt, female_samples.txt)
  - Handles multiple FASTQ naming conventions
  - Runs Bowtie2 mapping
  - Creates and indexes BAM files
  - Works inside Docker container

### 2. Updated Docker Compose
- **File**: `web_interface/docker-compose.yml`
- **Added volume mounts**:
  - Reference genome: `../ncbi_dataset`
  - Bowtie2 index: `../data/bowtie2_index`

### 3. Updated Backend Code
- **File**: `web_interface/backend/app.py`
- **Changes**:
  - Added reference genome and Bowtie2 index detection
  - Added volume mounts for Step 0
  - Creates sample list files if missing
  - Validates sample lists have content
  - Implements Step 0 execution
  - Auto-runs Step 1 after Step 0 completes

## 📋 What You Need to Do

### 1. Rebuild Backend Container
```bash
cd web_interface
docker-compose build backend
docker-compose up -d backend
```

### 2. Add Sample Lists
Before running Step 0, you need to add sample IDs:

**Option A: Via Web Interface** (if implemented)
- Upload/edit `male_samples.txt` and `female_samples.txt`

**Option B: Manually**
- Edit `web_interface/uploads/Step_0/male_samples.txt`
- Edit `web_interface/uploads/Step_0/female_samples.txt`
- Add one sample ID per line (matching your FASTQ file names)

Example:
```
sample_male_1
sample_male_2
```

### 3. Upload FASTQ Files
- Upload your FASTQ files via web interface
- Files should be named: `sample_name_R1.fastq` and `sample_name_R2.fastq`
- Or: `sample_name_1.fastq` and `sample_name_2.fastq`

### 4. Run Step 0
- Select "FASTQ Files" as data type
- Click "Start Pipeline"
- Step 0 will run, then automatically run Step 1

## ⚠️ Requirements

### Must Have:
- ✅ Reference genome file (already in your project)
- ✅ Bowtie2 index files (already in your project)
- ✅ Sample lists with actual sample IDs
- ✅ FASTQ files uploaded

### File Locations:
```
SexFindR/
├── ncbi_dataset/                    ← Reference genome (mounted)
│   └── ncbi_dataset/
│       └── data/
│           └── GCA_907165135.1/
│               └── GCA_907165135.1_OKI2018_I68_1.0_genomic.fna
│
├── data/
│   └── bowtie2_index/               ← Bowtie2 index (mounted)
│       └── Oikopleura_dioica.*.bt2
│
└── web_interface/
    └── uploads/
        ├── data/
        │   └── fastq/               ← Upload FASTQ files here
        └── Step_0/
            ├── male_samples.txt     ← Add sample IDs here
            └── female_samples.txt   ← Add sample IDs here
```

## 🧪 Testing

1. **Upload FASTQ files** via web interface
2. **Add sample IDs** to sample list files
3. **Run pipeline** - Step 0 should execute
4. **Check results** - BAM files should be in `uploads/data/bams/`
5. **Step 1 should run automatically** after Step 0

## 🐛 Troubleshooting

### "Reference genome not found"
- Check that `ncbi_dataset` folder exists in project root
- Verify path in docker-compose.yml is correct

### "Bowtie2 index not found"
- Check that `data/bowtie2_index` folder exists
- Verify it contains `.bt2` files

### "Sample lists are empty"
- Edit `uploads/Step_0/male_samples.txt` and `female_samples.txt`
- Add sample IDs (one per line, no comments)

### "FASTQ files not found"
- Check file names match sample IDs
- Try different naming conventions (see script for supported formats)

## 📝 Next Steps

After implementation:
1. Test with sample FASTQ files
2. Verify BAM files are created correctly
3. Ensure Step 1 runs automatically
4. Add UI for sample list editing (optional enhancement)




