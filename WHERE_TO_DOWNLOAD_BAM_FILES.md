# Where to Download BAM Files

## 🎯 Quick Answer

You can download BAM files (or FASTQ files to create BAM files) from these sources:

1. **NCBI SRA (Sequence Read Archive)** - Most common
2. **ENA (European Nucleotide Archive)**
3. **GSA (Genome Sequence Archive)**
4. **Published research papers** (supplementary data)

## 📥 Option 1: NCBI SRA (Recommended)

### Website:
**https://www.ncbi.nlm.nih.gov/sra**

### How to Download:

1. **Search for your species:**
   - Go to https://www.ncbi.nlm.nih.gov/sra
   - Search for your species name (e.g., "Takifugu rubripes" or "Oikopleura dioica")
   - Filter by sex if available

2. **Find male and female samples:**
   - Look for samples labeled as "male" or "female"
   - Check sample descriptions/metadata

3. **Download options:**

   **Option A: Download FASTQ files (then convert to BAM in Step 0)**
   - Click on a sample
   - Click "Download" → Select "FASTQ files"
   - Download both R1 and R2 files for paired-end sequencing
   - Then use Step 0 to create BAM files

   **Option B: Use SRA Toolkit (command line)**
   ```bash
   # Install SRA Toolkit first
   # Download from: https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit
   
   # Download FASTQ files
   fastq-dump --split-files SRR8585998  # Male sample
   fastq-dump --split-files SRR8585999  # Female sample
   ```

### Example SRA Accessions:
- **Male sample**: SRR8585998
- **Female sample**: SRR8585999

## 📥 Option 2: ENA (European Nucleotide Archive)

### Website:
**https://www.ebi.ac.uk/ena/browser/home**

### How to Download:

1. Go to https://www.ebi.ac.uk/ena/browser/home
2. Search for your species
3. Filter by sex if metadata available
4. Download FASTQ files
5. Convert to BAM using Step 0

## 📥 Option 3: Published Research Papers

Many research papers provide their sequencing data as supplementary material:

1. **Search for papers** on your species
2. **Check supplementary data** sections
3. **Look for data repositories** mentioned in papers:
   - Dryad
   - Figshare
   - Zenodo
   - Author's lab website

## 📥 Option 4: Direct BAM File Downloads

Some databases provide pre-aligned BAM files:

### Ensembl
- **Website**: https://www.ensembl.org
- Some species have pre-aligned BAM files
- Usually requires registration

### Galaxy Project
- **Website**: https://usegalaxy.org
- Has public datasets
- Can download BAM files directly

## 🔄 Option 5: Download FASTQ and Create BAM (Most Common)

**Most people download FASTQ files and create BAM files using Step 0:**

### Step-by-Step:

1. **Download FASTQ files from SRA:**
   ```bash
   # Example: Download male sample
   fastq-dump --split-files SRR8585998
   # This creates: SRR8585998_1.fastq and SRR8585998_2.fastq
   
   # Example: Download female sample
   fastq-dump --split-files SRR8585999
   # This creates: SRR8585999_1.fastq and SRR8585999_2.fastq
   ```

2. **Put FASTQ files in your project:**
   ```
   data/fastq/
   ├── SRR8585998_1.fastq  (male R1)
   ├── SRR8585998_2.fastq  (male R2)
   ├── SRR8585999_1.fastq  (female R1)
   └── SRR8585999_2.fastq  (female R2)
   ```

3. **Run Step 0 to create BAM files:**
   - Step 0 will align FASTQ files to reference genome
   - Creates BAM files in `data/bams/`
   - Then use those BAM files for Step 1

## 🎯 Recommended Workflow

### For Beginners:

1. **Go to NCBI SRA**: https://www.ncbi.nlm.nih.gov/sra
2. **Search for your species** + "male" or "female"
3. **Find 2 samples** (1 male, 1 female)
4. **Download FASTQ files** (not BAM)
5. **Use Step 0** to create BAM files
6. **Use those BAM files** for Step 1

### Example Search Terms:
- "Takifugu rubripes male"
- "Oikopleura dioica female"
- "Your species name" + "sex chromosome"

## 📋 What to Look For

When searching for samples, look for:
- ✅ **Sex information** in metadata (male/female)
- ✅ **Same sequencing platform** (if possible)
- ✅ **Similar coverage depth** (both ~20-30x)
- ✅ **Same reference genome** alignment
- ✅ **Recent data** (if available)

## 🔧 Tools for Downloading

### SRA Toolkit (Command Line)
```bash
# Download from: https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit

# Download FASTQ
fastq-dump --split-files SRR12345678

# Download with compression
fastq-dump --split-files --gzip SRR12345678
```

### SRA Browser (GUI)
- Download from NCBI website
- Point-and-click interface
- Good for beginners

### ENA Browser
- Web-based download
- No installation needed
- Direct download links

## 💡 Tips

1. **Start with well-studied species**: Easier to find male/female pairs
2. **Check paper methods**: Authors often list SRA accessions
3. **Use same study**: Samples from same study are more comparable
4. **Check file sizes**: BAM files are large (often 1-10 GB each)
5. **FASTQ is more common**: Most databases have FASTQ, not BAM

## 🚨 Important Notes

- **BAM files are large**: Often 1-10 GB each
- **FASTQ files are also large**: Similar size
- **You need both sexes**: One male + one female
- **Same reference genome**: Both should align to same reference
- **Internet speed matters**: Large files take time to download

## 📚 Example: Finding Fugu Samples

1. Go to: https://www.ncbi.nlm.nih.gov/sra
2. Search: "Takifugu rubripes"
3. Look for samples with sex information
4. Example accessions from papers:
   - SRR8585998 (male)
   - SRR8585999 (female)
5. Download FASTQ files
6. Convert to BAM using Step 0

## 🆘 If You Can't Find BAM Files

**Don't worry!** Most people:
1. Download FASTQ files (more common)
2. Use Step 0 to create BAM files
3. Then use those BAM files for Step 1

This is actually the **recommended approach** because:
- More FASTQ files available
- You control the alignment quality
- You can use your reference genome

## Quick Links

- **NCBI SRA**: https://www.ncbi.nlm.nih.gov/sra
- **ENA**: https://www.ebi.ac.uk/ena/browser/home
- **SRA Toolkit**: https://github.com/ncbi/sra-tools
- **Galaxy**: https://usegalaxy.org

## Summary

**Best approach:**
1. Download FASTQ files from NCBI SRA
2. Use Step 0 to create BAM files
3. Use those BAM files for Step 1

**Direct BAM download:**
- Less common
- May not match your reference genome
- Harder to find male/female pairs




