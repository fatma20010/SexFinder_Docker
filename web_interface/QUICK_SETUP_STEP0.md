# Quick Setup for Step 0 - FASTQ Mapping

## What You Need

To make Step 0 work, you need:

### ✅ Already Available:
1. **Reference Genome** - `ncbi_dataset/ncbi_dataset/data/GCA_907165135.1/GCA_907165135.1_OKI2018_I68_1.0_genomic.fna`
2. **Bowtie2 Index** - `data/bowtie2_index/Oikopleura_dioica.*.bt2`
3. **Mapping Script** - Created at `web_interface/Step_0/run_step0_mapping.sh`

### ⚠️ You Need to Provide:
1. **Sample Lists** - Add your sample IDs
2. **FASTQ Files** - Upload via web interface

## Quick Setup Steps

### Step 1: Rebuild Backend
```bash
cd web_interface
docker-compose build backend
docker-compose up -d backend
```

### Step 2: Add Sample IDs

Create/edit these files in `web_interface/uploads/Step_0/`:

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

### Step 3: Upload FASTQ Files

Via web interface:
1. Select "FASTQ Files" as data type
2. Upload your FASTQ files
3. Files should be named like: `sample_male_1_R1.fastq` and `sample_male_1_R2.fastq`

### Step 4: Run Pipeline

Click "Start Pipeline" - Step 0 will:
1. Map FASTQ files to reference genome
2. Create BAM files
3. Automatically run Step 1 with the BAM files

## File Structure

```
web_interface/
├── uploads/
│   ├── data/
│   │   └── fastq/          ← Upload FASTQ files here
│   └── Step_0/
│       ├── male_samples.txt    ← Add sample IDs
│       └── female_samples.txt  ← Add sample IDs
└── output/                 ← Results appear here
```

## That's It!

Once you:
- ✅ Rebuild backend
- ✅ Add sample IDs
- ✅ Upload FASTQ files

Step 0 will work! 🎉




