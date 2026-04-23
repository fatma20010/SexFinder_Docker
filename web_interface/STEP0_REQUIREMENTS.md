# Step 0 Requirements - What's Needed to Make It Work

## Current Status
❌ Step 0 is **NOT working** in the web interface  
✅ Step 1 (BAM files) **IS working**

## What Step 0 Needs

### 1. **Reference Genome File** ✅ (Available)
- **Location**: `ncbi_dataset/ncbi_dataset/data/GCA_907165135.1/GCA_907165135.1_OKI2018_I68_1.0_genomic.fna`
- **Status**: File exists in your project
- **Action**: Mount this file in Docker

### 2. **Bowtie2 Index Files** ✅ (Available)
- **Location**: `data/bowtie2_index/Oikopleura_dioica.*.bt2`
- **Status**: Index files exist (you have 6 .bt2 files)
- **Action**: Mount the index directory in Docker

### 3. **Sample Lists** ⚠️ (Need to Create/Upload)
- **Files**: 
  - `Step_0/male_samples.txt` - List of male sample IDs
  - `Step_0/female_samples.txt` - List of female sample IDs
- **Status**: Template files exist, but need actual sample IDs
- **Action**: Allow users to upload/edit these files in web interface

### 4. **Mapping Script** ✅ (Available)
- **Script**: `Step_0/bowtie2_16_linux.sh` or create new one
- **Status**: Script exists
- **Action**: Use this script or create Docker-compatible version

### 5. **FASTQ Files** ⚠️ (User Uploads)
- **Location**: `data/fastq/`
- **Status**: Users upload these
- **Action**: Already working ✅

### 6. **Tools in Docker Image** ✅ (Should be available)
- **Bowtie2**: Should be in sexfindr:latest image
- **SAMtools**: Should be in sexfindr:latest image
- **Status**: Need to verify

## Implementation Plan

### Phase 1: Add Volume Mounts (Required)
Update `docker-compose.yml` or Docker command to mount:
```yaml
volumes:
  - ./ncbi_dataset:/sexfindr/ncbi_dataset  # Reference genome
  - ./data/bowtie2_index:/sexfindr/data/bowtie2_index  # Bowtie2 index
```

### Phase 2: Sample List Management (Required)
Add to web interface:
- Upload/edit `male_samples.txt`
- Upload/edit `female_samples.txt`
- Validate sample IDs match FASTQ file names

### Phase 3: Create Step 0 Script (Required)
Create `run_step0_mapping.sh` that:
- Reads sample lists
- Finds FASTQ files for each sample
- Runs Bowtie2 mapping
- Creates BAM files
- Works inside Docker container

### Phase 4: Update Backend (Required)
Update `backend/app.py` to:
- Mount reference genome and index
- Create/validate sample lists
- Run Step 0 script
- Handle errors gracefully

## Quick Implementation Checklist

- [ ] Mount reference genome in Docker
- [ ] Mount Bowtie2 index in Docker  
- [ ] Add sample list upload/edit in frontend
- [ ] Create `run_step0_mapping.sh` script
- [ ] Update backend to handle Step 0
- [ ] Test with sample FASTQ files
- [ ] Verify BAM files are created
- [ ] Ensure BAM files work with Step 1

## Files That Need to Be Mounted

```
SexFindR/
├── ncbi_dataset/                    ← Mount this (reference genome)
│   └── ncbi_dataset/
│       └── data/
│           └── GCA_907165135.1/
│               └── GCA_907165135.1_OKI2018_I68_1.0_genomic.fna
│
├── data/
│   └── bowtie2_index/               ← Mount this (Bowtie2 index)
│       └── Oikopleura_dioica.*.bt2
│
└── Step_0/
    ├── male_samples.txt             ← Create/edit in web interface
    └── female_samples.txt           ← Create/edit in web interface
```

## Estimated Implementation Time

- **Quick fix (basic)**: 2-3 hours
- **Full implementation (with UI)**: 4-6 hours

## Alternative: Use BAM Files Instead

**Easier solution**: Skip Step 0, use BAM files directly
- ✅ Already working
- ✅ No additional setup needed
- ✅ Faster workflow




