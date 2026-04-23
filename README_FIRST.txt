================================================================================
                    SEXFINDR PIPELINE - START HERE!
================================================================================

Welcome! This is a simple guide to get you started.

FOR NON-TECHNICAL USERS:
-------------------------
Windows Users:
1. Read: FOR_PROFESSOR.md (simple step-by-step guide)
2. Follow the instructions there
3. If you have problems, check: TROUBLESHOOTING.md

macOS Users:
1. Read: FOR_PROFESSOR_MACOS.md (simple step-by-step guide)
2. Follow the instructions there
3. If you have problems, check: TROUBLESHOOTING.md

QUICK START (3 Steps):
----------------------
WINDOWS:
1. Install Docker Desktop (one-time setup)
   - Download from: https://www.docker.com/products/docker-desktop
   - Install it

2. Load the pipeline (one-time setup)
   - Double-click: LOAD_DOCKER.bat
   - Wait until it says "Done!"

3. Run your analysis (every time)
   - Add your data files to: data\fastq\ (or bams\ or vcfs\)
   - Add sample names to: Step_0\male_samples.txt and female_samples.txt
   - Double-click: RUN_PIPELINE.bat
   - Wait for results in: output\ folder

macOS:
1. Install Docker Desktop for Mac (one-time setup)
   - Download from: https://www.docker.com/products/docker-desktop
   - Install it

2. Load the pipeline (one-time setup)
   - Open Terminal
   - Navigate to SexFindR folder: cd /path/to/SexFindR
   - Make scripts executable: chmod +x load_docker.sh run_pipeline.sh
   - Run: ./load_docker.sh
   - Wait until it says "Success!"

3. Run your analysis (every time)
   - Add your data files to: data/fastq/ (or bams/ or vcfs/)
   - Add sample names to: Step_0/male_samples.txt and female_samples.txt
   - In Terminal: ./run_pipeline.sh
   - Wait for results in: output/ folder

FILES YOU NEED:
---------------
Windows:
- LOAD_DOCKER.bat - Load the pipeline (run once)
- RUN_PIPELINE.bat - Run your analysis (run every time)
- FOR_PROFESSOR.md - Detailed instructions

macOS:
- load_docker.sh - Load the pipeline (run once)
- run_pipeline.sh - Run your analysis (run every time)
- FOR_PROFESSOR_MACOS.md - Detailed instructions

Both:
- TROUBLESHOOTING.md - Help with problems

WHAT'S INCLUDED:
----------------
- All software needed (R, Bowtie2, SAMtools, etc.)
- Reference genome (Oikopleura dioica)
- Pipeline scripts
- Everything pre-configured

YOU JUST NEED TO:
-----------------
- Add your data files
- Add your sample names
- Click RUN_PIPELINE.bat

That's it! The pipeline does everything else automatically.

================================================================================
Need help? Check TROUBLESHOOTING.md or FOR_PROFESSOR.md
================================================================================


