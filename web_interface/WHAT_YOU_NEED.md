# What You Need to Make Step 0 Work

## Summary

I've implemented Step 0 support! Here's what's needed:

## ✅ What I've Done

1. **Created Step 0 mapping script** - `web_interface/Step_0/run_step0_mapping.sh`
2. **Updated backend** - Handles Step 0 execution
3. **Updated docker-compose** - Mounts reference genome and Bowtie2 index
4. **Auto-creates sample lists** - Creates template files if missing

## 📋 What You Need to Do

### 1. Rebuild Backend (Required)
```bash
cd web_interface
docker-compose build backend
docker-compose up -d backend
```

### 2. Add Sample IDs (Required)

Edit these files in `web_interface/uploads/Step_0/`:

**male_samples.txt:**
```
sample_male_1
sample_male_2
```

**female_samples.txt:**
```
sample_female_1
sample_female_2
```

**Important:** Sample IDs must match your FASTQ file names (without `_R1`/`_R2`).

For example, if your files are:
- `sample_male_1_R1.fastq` and `sample_male_1_R2.fastq`
- Then the sample ID should be: `sample_male_1`

### 3. Upload FASTQ Files (Required)

Via web interface:
- Select "FASTQ Files" as data type
- Upload your FASTQ files
- Files should be named: `sample_name_R1.fastq` and `sample_name_R2.fastq`

### 4. Run Pipeline

Click "Start Pipeline" - it will:
1. Run Step 0 (map FASTQ to BAM)
2. Automatically run Step 1 (DifCover analysis)

## ✅ What's Already Available

- ✅ Reference genome file (in your project)
- ✅ Bowtie2 index files (in your project)
- ✅ Mapping script (created)
- ✅ Backend code (updated)

## 📁 File Locations

```
SexFindR/
├── ncbi_dataset/                    ← Reference genome (auto-mounted)
│   └── ncbi_dataset/
│       └── data/
│           └── GCA_907165135.1/
│               └── GCA_907165135.1_OKI2018_I68_1.0_genomic.fna
│
├── data/
│   └── bowtie2_index/               ← Bowtie2 index (auto-mounted)
│       └── Oikopleura_dioica.*.bt2
│
└── web_interface/
    └── uploads/
        ├── data/
        │   └── fastq/               ← Upload FASTQ files here
        └── Step_0/
            ├── male_samples.txt     ← Add sample IDs here ⚠️
            └── female_samples.txt   ← Add sample IDs here ⚠️
```

## 🎯 Quick Checklist

- [ ] Rebuild backend: `docker-compose build backend && docker-compose up -d backend`
- [ ] Add sample IDs to `uploads/Step_0/male_samples.txt`
- [ ] Add sample IDs to `uploads/Step_0/female_samples.txt`
- [ ] Upload FASTQ files via web interface
- [ ] Run pipeline

## That's It!

Once you complete the checklist above, Step 0 will work! 🎉

The system will:
1. Map your FASTQ files to the reference genome
2. Create BAM files
3. Automatically run Step 1 with the BAM files




