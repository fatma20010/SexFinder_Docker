# SexFindR Pipeline Explanation

## What Does SexFindR Do?

**SexFindR** is a computational workflow designed to **identify sex chromosomes** in genomes. It helps researchers find which chromosomes are sex chromosomes (like X and Y in humans) by analyzing differences between male and female genomes.

### The Big Picture

Sex chromosomes have different characteristics:
- **Coverage differences**: One sex might have more/less DNA coverage in certain regions
- **Sequence differences**: Different variants (SNPs) between males and females
- **Structural differences**: Different arrangements or densities of genetic markers

SexFindR combines multiple analysis methods to find these patterns and identify sex chromosomes.

---

## The 4-Step Pipeline

### **Step 0: Mapping and Variant Calling**
**Input**: Raw sequencing reads (FASTQ files)  
**Output**: Aligned reads (BAM files) and variants (VCF files)

**What it does:**
1. Maps sequencing reads to a reference genome using **Bowtie2**
2. Converts alignments to BAM format using **SAMtools**
3. Calls genetic variants (SNPs) using variant callers
4. Creates indexed BAM files for downstream analysis

**Why**: You need aligned data to compare male vs female genomes

---

### **Step 1: Coverage-Based Analysis (DifCover)**
**Input**: BAM files from males and females  
**Output**: Regions with different coverage between sexes

**What it does:**
1. Compares read coverage between male and female BAM files
2. Calculates coverage ratios in windows across the genome
3. Identifies regions where:
   - Males have significantly more coverage → potential Y chromosome regions
   - Females have significantly more coverage → potential W chromosome regions
4. Uses **DifCover** tool to find these differences

**Key Concept**: Sex chromosomes often have different copy numbers:
- Males: XY (one X, one Y)
- Females: XX (two X chromosomes)
- So X chromosome regions have 2x coverage in females vs males

**Output**: Files showing which genomic regions have different coverage ratios

---

### **Step 2: Sequence-Based Analyses**
**Input**: VCF files (variant calls)  
**Output**: Multiple analyses identifying sex-linked regions

This step runs **4 different analyses**:

#### 2A. **Fst Analysis** (Fixation Index)
- Measures genetic differentiation between populations
- High Fst = regions that differ significantly between males and females
- Sex chromosomes should show high Fst values

#### 2B. **GWAS** (Genome-Wide Association Study)
- Tests which genomic regions are associated with sex
- Uses tools like **PLINK** or **GEMMA**
- Finds variants that correlate with being male vs female

#### 2C. **k-mer GWAS**
- Analyzes short DNA sequences (k-mers) instead of single variants
- Can find sex-linked sequences that might be missed by SNP analysis
- Useful for finding structural differences

#### 2D. **SNP Density**
- Counts how many variants occur per region
- Sex chromosomes often have:
  - Lower SNP density (less recombination)
  - Different patterns of variation

**Why Multiple Methods?**: Each method finds different types of evidence. Combining them gives stronger confidence.

---

### **Step 3: Combined Analysis**
**Input**: Results from Step 1 and Step 2  
**Output**: Final identification of sex chromosomes

**What it does:**
1. Combines evidence from all previous steps
2. Ranks genomic regions by:
   - Coverage differences (Step 1)
   - Fst values (Step 2A)
   - GWAS significance (Step 2B)
   - SNP density patterns (Step 2D)
3. Identifies regions that show evidence across multiple methods
4. Creates visualizations and final reports

**Goal**: Find regions that consistently show sex-linked patterns across all analyses

---

## Data Flow Diagram

```
FASTQ files (raw reads)
    ↓
Step 0: Mapping & Variant Calling
    ↓
BAM files (aligned) + VCF files (variants)
    ↓
    ├─→ Step 1: DifCover (coverage analysis)
    │       ↓
    │   Coverage differences
    │
    └─→ Step 2: Sequence analyses
            ├─→ Fst analysis
            ├─→ GWAS
            ├─→ k-mer GWAS
            └─→ SNP Density
                ↓
            Sequence differences
    ↓
Step 3: Combine all evidence
    ↓
Final Sex Chromosome Identification
```

---

## Relationship with Snakemake

### **Important: SexFindR does NOT use Snakemake**

**Current Implementation:**
- Uses **bash shell scripts** (`.sh` files)
- Manual step-by-step execution
- Each step is run individually
- No workflow management system

**Why No Snakemake?**
- The original pipeline was designed as a collection of scripts
- Each step can be run independently
- Users can start at different steps depending on their data
- Simpler for non-computational users

### **Could You Use Snakemake?**

**Yes, you could convert it!** Snakemake would provide:

**Advantages:**
- ✅ Automatic dependency management
- ✅ Parallel execution of independent tasks
- ✅ Automatic rerunning of failed steps
- ✅ Better reproducibility
- ✅ Easier to scale to many samples

**Example Snakemake Structure:**
```python
# Hypothetical Snakefile
rule all:
    input: "output/sex_chromosomes_identified.txt"

rule map_reads:
    input: "data/fastq/{sample}_R1.fastq", "data/fastq/{sample}_R2.fastq"
    output: "data/bams/{sample}.bam"
    shell: "bowtie2 -x {params.index} -1 {input[0]} -2 {input[1]} | samtools view -bS - > {output}"

rule difcover:
    input: "data/bams/{male}.bam", "data/bams/{female}.bam"
    output: "output/difcover/{male}_{female}.out"
    shell: "bash Step_1/run_difcover.sh {input[0]} {input[1]} 1"
```

**Current vs Snakemake:**

| Feature | Current (Bash) | With Snakemake |
|---------|---------------|----------------|
| Execution | Manual, step-by-step | Automatic workflow |
| Parallelization | Manual | Automatic |
| Dependency tracking | Manual | Automatic |
| Error handling | Manual | Automatic retry |
| Reproducibility | Good | Excellent |
| Learning curve | Easy | Moderate |

---

## Tools Used in Each Step

### Step 0:
- **Bowtie2**: Read alignment
- **SAMtools**: BAM file processing
- **Variant callers**: SNP calling

### Step 1:
- **DifCover**: Coverage difference analysis
- **R**: Statistical analysis and visualization

### Step 2:
- **VCFtools**: VCF file processing
- **PLINK/GEMMA**: GWAS analysis
- **R**: Statistical analysis
- **Python**: k-mer analysis

### Step 3:
- **R**: Data integration and visualization
- **Python**: Window-based analysis

---

## Key Concepts

### 1. **Coverage Ratio**
- If females have 2x coverage in a region compared to males → likely X chromosome
- If males have unique coverage → likely Y chromosome

### 2. **Fst (Fixation Index)**
- Measures how different two populations are
- High Fst between males and females → sex-linked region

### 3. **GWAS**
- Finds genetic variants associated with a trait (sex)
- Sex chromosomes should show strong associations

### 4. **SNP Density**
- Sex chromosomes often have different mutation/recombination rates
- Creates distinct patterns in variant density

---

## Why This Approach Works

1. **Multiple Lines of Evidence**: Combines coverage, sequence, and statistical analyses
2. **Comprehensive**: Looks at different aspects (coverage, variants, structure)
3. **Validated**: Used successfully on multiple species (fugu, chicken, lamprey, etc.)
4. **Flexible**: Can start at different steps depending on available data

---

## Summary

**SexFindR** is a **bash script-based pipeline** (not Snakemake) that:
1. Maps sequencing data to a reference genome
2. Compares male vs female genomes using multiple methods
3. Identifies sex chromosomes by finding regions with consistent sex-linked patterns
4. Combines evidence from coverage and sequence analyses

The pipeline is designed to be **simple and flexible**, allowing users to run steps independently based on their data and needs.

