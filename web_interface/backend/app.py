"""
SexFindR Web Interface - Backend API
Flask backend for running the SexFindR pipeline via web interface
"""

from flask import Flask, request, jsonify, send_file, send_from_directory
from flask_cors import CORS
import os
import subprocess
import json
import threading
import time
from datetime import datetime
from werkzeug.utils import secure_filename
import zipfile
import shutil
import re


def sanitize_user_host_path(raw):
    """Remove outer quotes / file:// prefixes from paths pasted in the UI or saved with bad JSON."""
    if raw is None:
        return ''
    s = str(raw).strip()
    while len(s) >= 2 and s[0] == s[-1] and s[0] in '"\'':
        s = s[1:-1].strip()
    low = s.lower()
    if low.startswith('file:///'):
        s = s[8:]
    elif low.startswith('file://'):
        s = s[7:]
    s = s.strip().replace('\\', '/')
    # file:///C:/... can appear as /C:/... — drop leading slash before drive letter
    if s.startswith('/') and len(s) >= 3 and s[2] == ':' and s[1].isalpha():
        s = s[1:]
    return s


def docker_host_bind_src(path):
    """
    Windows + Docker Desktop: '-v C:/host/path:/container' is parsed as three colon-separated
    segments, so Docker treats '/container' as an invalid volume mode. Use '//c/host/path'.
    Safe for Linux/mac paths (unchanged unless they match an X:/... drive pattern).
    """
    if not path:
        return path
    p = sanitize_user_host_path(path).replace('\\', '/')
    if len(p) >= 2 and p[1] == ':':
        if len(p) == 2:
            drive = p[0].lower()
            return f'//{drive}/'
        if p[2] == '/':
            drive = p[0].lower()
            rest = p[3:]
            return f'//{drive}/{rest}'
    return p


def bowtie2_host_dir_for_mount(path):
    """Bowtie2 mount must be a directory; users often paste a .bt2 file path."""
    p = sanitize_user_host_path(path)
    if not p:
        return ''
    p = p.replace('\\', '/')
    low = p.lower()
    if low.endswith('.bt2'):
        parent = p.rsplit('/', 1)[0]
        return docker_host_bind_src(parent)
    return docker_host_bind_src(p)


app = Flask(__name__)
CORS(app)  # Enable CORS for frontend

# Configuration
UPLOAD_FOLDER = 'uploads'
OUTPUT_FOLDER = 'output'
ALLOWED_EXTENSIONS = {'fastq', 'fq', 'bam', 'vcf', 'gz'}
MAX_FILE_SIZE = 10 * 1024 * 1024 * 1024  # 10GB max file size

# Pipeline status tracking
pipeline_status = {
    'status': 'idle',  # idle, running, completed, error
    'current_step': None,
    'progress': 0,
    'message': '',
    'start_time': None,
    'end_time': None,
    'results': {}
}
# Data type selected by user in the UI (bam, fastq, vcf) - used instead of auto-detect when set
pipeline_run_data_type = None
# Adjustment coefficient from UI (Step 2: Configure Parameters) — must match run_difcover.sh 3rd arg
pipeline_adjustment_coefficient = 1.0
# Reference to the background worker thread (detect stale "running" state)
pipeline_run_thread = None

# Ensure directories exist - use /app paths if in Docker, otherwise relative
if os.path.exists('/app'):
    UPLOAD_FOLDER = '/app/uploads'
    OUTPUT_FOLDER = '/app/output'
else:
    UPLOAD_FOLDER = 'uploads'
    OUTPUT_FOLDER = 'output'

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)
os.makedirs(os.path.join(UPLOAD_FOLDER, 'data', 'fastq'), exist_ok=True)
os.makedirs(os.path.join(UPLOAD_FOLDER, 'data', 'bams'), exist_ok=True)
os.makedirs(os.path.join(UPLOAD_FOLDER, 'data', 'vcfs'), exist_ok=True)
for step_num in [0, 1, 2, 3]:
    os.makedirs(os.path.join(UPLOAD_FOLDER, f'Step_{step_num}'), exist_ok=True)


def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def detect_data_type():
    """Detect what type of data files are present"""
    # Inside Docker container, uploads are at /app/uploads
    if os.path.exists('/app'):
        upload_dir = '/app/uploads'
    else:
        # Running locally
        backend_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(backend_dir)
        upload_dir = os.path.join(project_root, 'uploads')
    
    fastq_dir = os.path.join(upload_dir, 'data', 'fastq')
    bam_dir = os.path.join(upload_dir, 'data', 'bams')
    vcf_dir = os.path.join(upload_dir, 'data', 'vcfs')
    
    if os.path.exists(fastq_dir):
        try:
            files = os.listdir(fastq_dir)
            if any(f.endswith(('.fastq', '.fq', '.fastq.gz', '.fq.gz')) for f in files):
                return 'fastq'
        except:
            pass
    
    if os.path.exists(bam_dir):
        try:
            files = os.listdir(bam_dir)
            if any(f.endswith('.bam') for f in files):
                return 'bam'
        except:
            pass
    
    if os.path.exists(vcf_dir):
        try:
            files = os.listdir(vcf_dir)
            if any(f.endswith(('.vcf', '.vcf.gz')) for f in files):
                return 'vcf'
        except:
            pass
    
    return None


def run_pipeline_step(step, data_type=None, adjustment_coefficient=1.0):
    """Run a specific pipeline step using Docker"""
    global pipeline_status
    
    # Inside Docker container, working directory is /app
    # Uploads are mounted at /app/uploads, output at /app/output
    # Use these paths directly instead of calculating relative paths
    if os.path.exists('/app'):
        # Running inside Docker container
        upload_dir = '/app/uploads'
        output_dir = '/app/output'
    else:
        # Running locally (development)
        backend_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(backend_dir)
        upload_dir = os.path.join(project_root, 'uploads')
        output_dir = os.path.join(project_root, OUTPUT_FOLDER)
    
    # Ensure directories exist
    os.makedirs(upload_dir, exist_ok=True)
    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(os.path.join(upload_dir, 'data', 'bams'), exist_ok=True)
    os.makedirs(os.path.join(upload_dir, 'data', 'fastq'), exist_ok=True)
    os.makedirs(os.path.join(upload_dir, 'data', 'vcfs'), exist_ok=True)
    for step_num in [0, 1, 2, 3]:
        os.makedirs(os.path.join(upload_dir, f'Step_{step_num}'), exist_ok=True)
    
    # Pipeline paths come from frontend only (no hardcoded backend paths)
    pipeline_paths = load_pipeline_paths()
    ref_genome_host = (pipeline_paths.get('reference_genome_path') or '').strip()
    bowtie2_index_host = (pipeline_paths.get('bowtie2_index_path') or '').strip()

    # Fixed paths inside the pipeline container (we mount user paths here)
    ref_genome_container = '/sexfindr/reference/genome.fna'
    bowtie2_index_container = '/sexfindr/data/bowtie2_index'

    config_path = os.path.join(upload_dir, 'config.sh')
    if not os.path.exists(config_path):
        try:
            with open(config_path, 'w', encoding='utf-8') as f:
                f.write('#!/bin/bash\n')
                f.write('ADJUSTMENT_COEFFICIENT=1.0\n')
                f.write(f'REFERENCE_GENOME={ref_genome_container}\n')
                f.write(f'BOWTIE2_INDEX={bowtie2_index_container}/Oikopleura_dioica\n')
                f.write('THREADS=8\n')
            if os.name != 'nt':
                os.chmod(config_path, 0o755)
        except Exception as e:
            print(f"Warning: Could not create config.sh: {e}")

    def norm(p):
        """Normalize host path for docker -v (handles Windows drive letters for Docker Desktop)."""
        if not p:
            return p
        p = str(p).strip()
        if os.path.exists('/app'):
            out = p.replace('\\', '/')
        else:
            out = os.path.abspath(p).replace('\\', '/')
        return docker_host_bind_src(out)

    if os.path.exists('/app'):
        host_uploads = os.environ.get('HOST_UPLOADS_PATH') or upload_dir
        host_output = os.environ.get('HOST_OUTPUT_PATH') or output_dir
        upload_dir_abs = norm(host_uploads)
        output_dir_abs = norm(host_output)
        config_path_abs = norm(os.path.join(host_uploads, 'config.sh'))
    else:
        upload_dir_abs = upload_dir.replace('\\', '/')
        output_dir_abs = output_dir.replace('\\', '/')
        config_path_abs = config_path.replace('\\', '/')

    ref_genome_host_abs = norm(ref_genome_host) if ref_genome_host else ''
    bowtie2_index_host_abs = (
        bowtie2_host_dir_for_mount(bowtie2_index_host) if bowtie2_index_host else ''
    )

    docker_cmd = [
        'docker', 'run', '--rm',
        '-v', f'{upload_dir_abs}/data:/sexfindr/data',
        '-v', f'{upload_dir_abs}/Step_0:/sexfindr/Step_0',
        '-v', f'{upload_dir_abs}/Step_1:/sexfindr/Step_1',
        '-v', f'{upload_dir_abs}/Step_2:/sexfindr/Step_2',
        '-v', f'{upload_dir_abs}/Step_3:/sexfindr/Step_3',
        '-v', f'{config_path_abs}:/sexfindr/config.sh',
        '-v', f'{output_dir_abs}:/sexfindr/output',
    ]
    if ref_genome_host_abs:
        docker_cmd.extend(['-v', f'{ref_genome_host_abs}:{ref_genome_container}'])
    if bowtie2_index_host_abs:
        docker_cmd.extend(['-v', f'{bowtie2_index_host_abs}:{bowtie2_index_container}'])

    docker_cmd.append('sexfindr:latest')
    
    if step == 1 and data_type == 'bam':
        # Step 1: DifCover analysis
        bam_dir = os.path.join(upload_dir, 'data', 'bams')
        if not os.path.exists(bam_dir):
            raise Exception("BAM directory does not exist")
        bam_files = [f for f in os.listdir(bam_dir) if f.endswith('.bam')]
        if len(bam_files) < 2:
            raise Exception("Need at least 2 BAM files (one male, one female)")

        # Ensure run_difcover.sh exists in uploads/Step_1 with LF line endings (mount overwrites container script)
        step1_dir = os.path.join(upload_dir, 'Step_1')
        os.makedirs(step1_dir, exist_ok=True)
        script_path = os.path.join(step1_dir, 'run_difcover.sh')
        if os.path.exists('/app/step1_template/run_difcover.sh'):
            template_path = '/app/step1_template/run_difcover.sh'
        else:
            backend_dir = os.path.dirname(os.path.abspath(__file__))
            project_root = os.path.dirname(os.path.dirname(backend_dir))
            template_path = os.path.join(project_root, 'Step_1', 'run_difcover.sh')
        if os.path.exists(template_path):
            with open(template_path, 'rb') as f:
                content = f.read().replace(b'\r\n', b'\n')
            with open(script_path, 'wb') as f:
                f.write(content)
            if os.name != 'nt':
                os.chmod(script_path, 0o755)
        elif not os.path.exists(script_path):
            raise Exception(
                "Step 1 script run_difcover.sh not found. "
                "Please ensure it exists in step1_template or repo Step_1."
            )

        male_bam = bam_files[0]  # First BAM file
        female_bam = bam_files[1] if len(bam_files) > 1 else bam_files[0]
        ac = float(adjustment_coefficient)
        cmd = docker_cmd + [
            'bash', '-c',
            f'cd /sexfindr/Step_1 && bash run_difcover.sh '
            f'/sexfindr/data/bams/{male_bam} /sexfindr/data/bams/{female_bam} {ac}'
        ]
        
        pipeline_status['current_step'] = 'Step 1: DifCover Analysis'
        pipeline_status['message'] = f'Running DifCover: {male_bam} vs {female_bam}'
        
    elif step == 0 and data_type == 'fastq':
        # Step 0: Mapping FASTQ files to BAM
        # Check for required files
        step0_dir = os.path.join(upload_dir, 'Step_0')
        male_samples = os.path.join(step0_dir, 'male_samples.txt')
        female_samples = os.path.join(step0_dir, 'female_samples.txt')
        
        # Create sample list files if they don't exist (with instructions)
        if not os.path.exists(male_samples):
            os.makedirs(step0_dir, exist_ok=True)
            with open(male_samples, 'w') as f:
                f.write('# Male sample IDs - one per line\n')
                f.write('# Example:\n')
                f.write('# sample_male_1\n')
                f.write('# sample_male_2\n')
        
        if not os.path.exists(female_samples):
            os.makedirs(step0_dir, exist_ok=True)
            with open(female_samples, 'w') as f:
                f.write('# Female sample IDs - one per line\n')
                f.write('# Example:\n')
                f.write('# sample_female_1\n')
                f.write('# sample_female_2\n')
        
        # Check if sample lists have actual samples (not just comments)
        def has_samples(filename):
            if not os.path.exists(filename):
                return False
            with open(filename, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#'):
                        return True
            return False
        
        if not has_samples(male_samples) and not has_samples(female_samples):
            raise Exception(
                "Sample lists are empty. Please add sample IDs to the Male/Female sample lists above."
            )

        if not ref_genome_host or not bowtie2_index_host:
            raise Exception(
                "Pipeline paths are required for Step 0 (FASTQ mapping). "
                "Please fill in 'Reference genome path' and 'Bowtie2 index path' in the 'Pipeline paths' section above, then save."
            )
        # When running locally (not in Docker), optionally check that paths exist
        if not os.path.exists('/app'):
            if not os.path.exists(ref_genome_host):
                raise Exception(
                    f"Reference genome file not found at the path you entered:\n{ref_genome_host}\n"
                    "Please correct the path in the Pipeline paths section."
                )
            if not os.path.exists(bowtie2_index_host):
                raise Exception(
                    f"Bowtie2 index directory not found at the path you entered:\n{bowtie2_index_host}\n"
                    "Please correct the path in the Pipeline paths section."
                )
        
        # Always refresh Step 0 script from template with LF line endings (mount may have CRLF from Windows).
        script_path = os.path.join(step0_dir, 'run_step0_mapping.sh')
        if os.path.exists('/app/step0_template/run_step0_mapping.sh'):
            template_path = '/app/step0_template/run_step0_mapping.sh'
        else:
            template_path = os.path.join(
                os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                'Step_0', 'run_step0_mapping.sh'
            )
        if os.path.exists(template_path):
            with open(template_path, 'rb') as f:
                content = f.read().replace(b'\r\n', b'\n')
            with open(script_path, 'wb') as f:
                f.write(content)
            if os.name != 'nt':
                os.chmod(script_path, 0o755)
        elif not os.path.exists(script_path):
            raise Exception(
                "Step 0 mapping script not found. Please ensure run_step0_mapping.sh exists in step0_template or Step_0."
            )
        
        cmd = docker_cmd + [
            'bash', '-c',
            'cd /sexfindr/Step_0 && bash run_step0_mapping.sh'
        ]
        
        pipeline_status['current_step'] = 'Step 0: Mapping FASTQ files'
        pipeline_status['message'] = 'Mapping reads to reference genome...'

    elif step == 2 and data_type == 'vcf':
        # Step 2 (web UI): SNP density per VCF using VCFtools (installed in sexfindr image)
        vcf_dir = os.path.join(upload_dir, 'data', 'vcfs')
        if not os.path.exists(vcf_dir):
            raise Exception('VCF directory does not exist')
        vcf_files = [
            f for f in os.listdir(vcf_dir)
            if f.endswith('.vcf') or f.endswith('.vcf.gz')
        ]
        if not vcf_files:
            raise Exception('No VCF files found (.vcf or .vcf.gz)')

        step2_bash = r'''set -e
mkdir -p /sexfindr/output/Step_2/SNP_Density
cd /sexfindr/output/Step_2/SNP_Density
n=0
while IFS= read -r -d "" v; do
  n=$((n+1))
  bn=$(basename "$v")
  pref="${bn%.vcf.gz}"
  pref="${pref%.vcf}"
  if [[ "$v" == *.gz ]] || [[ "$v" == *.vcf.gz ]]; then
    vcftools --gzvcf "$v" --SNPdensity 10000 --out "${pref}_snpdensity"
  else
    vcftools --vcf "$v" --SNPdensity 10000 --out "${pref}_snpdensity"
  fi
done < <(find /sexfindr/data/vcfs -maxdepth 1 -type f \( -name "*.vcf" -o -name "*.vcf.gz" \) -print0)
if [ "$n" -eq 0 ]; then
  echo "No VCF files matched under /sexfindr/data/vcfs" >&2
  exit 1
fi
echo "Step 2: SNP density finished for ${n} file(s). Outputs in output/Step_2/SNP_Density/"
'''
        cmd = docker_cmd + ['bash', '-c', step2_bash]
        pipeline_status['current_step'] = 'Step 2: VCF — SNP density'
        pipeline_status['message'] = f'Running VCFtools SNP density on {len(vcf_files)} file(s)...'

    else:
        raise Exception(f"Step {step} not implemented for data type {data_type}")
    
    # Run the command
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
        universal_newlines=True
    )
    
    # Stream output and keep last lines for error reporting
    output_lines = []
    for line in process.stdout:
        pipeline_status['message'] = line.strip()
        print(line.strip())
        output_lines.append(line.strip())
        if len(output_lines) > 50:
            output_lines.pop(0)

    process.wait()

    if process.returncode != 0:
        tail = "\n".join(output_lines[-20:]) if output_lines else "(no output)"
        raise Exception(
            f"Pipeline step {step} failed with return code {process.returncode}. "
            f"Last output:\n{tail}"
        )
    
    return True


def run_pipeline_thread():
    """Run pipeline in a separate thread"""
    global pipeline_status, pipeline_run_data_type, pipeline_adjustment_coefficient, pipeline_run_thread

    try:
        pipeline_status['status'] = 'running'
        pipeline_status['start_time'] = datetime.now().isoformat()
        pipeline_status['progress'] = 10

        # Use data type selected by user in the UI; only auto-detect if not provided
        data_type = pipeline_run_data_type or detect_data_type()
        ac = float(pipeline_adjustment_coefficient)
        pipeline_run_data_type = None  # Reset after use
        pipeline_adjustment_coefficient = 1.0
        if not data_type:
            raise Exception("No data files detected. Please upload files first.")

        pipeline_status['message'] = f'Running pipeline for: {data_type}'
        pipeline_status['progress'] = 20
        
        # Run appropriate step
        if data_type == 'bam':
            run_pipeline_step(1, data_type, adjustment_coefficient=ac)
            pipeline_status['progress'] = 100
        elif data_type == 'fastq':
            # Step 0: Map FASTQ files to BAM
            run_pipeline_step(0, data_type)
            pipeline_status['progress'] = 50
            # After Step 0, BAM files should be available for Step 1
            if detect_data_type() == 'bam':
                pipeline_status['message'] = 'Step 0 complete. Running Step 1...'
                run_pipeline_step(1, 'bam', adjustment_coefficient=ac)
                pipeline_status['progress'] = 100
            else:
                pipeline_status['progress'] = 100
                pipeline_status['message'] = 'Step 0 complete. BAM files created. You can now run Step 1.'
        elif data_type == 'vcf':
            run_pipeline_step(2, data_type)
            pipeline_status['progress'] = 100

        # Collect results
        collect_results()
        
        pipeline_status['status'] = 'completed'
        pipeline_status['end_time'] = datetime.now().isoformat()
        pipeline_status['message'] = 'Pipeline completed successfully!'
        
    except Exception as e:
        pipeline_status['status'] = 'error'
        pipeline_status['message'] = f'Error: {str(e)}'
        pipeline_status['end_time'] = datetime.now().isoformat()
        print(f"Pipeline error: {e}")
    finally:
        pipeline_run_thread = None


def collect_results():
    """Collect output files from pipeline"""
    global pipeline_status
    
    results = {
        'step_0': [],
        'step_1': [],
        'step_2': [],
        'step_3': []
    }
    
    # Inside Docker container, paths are at /app/uploads and /app/output
    if os.path.exists('/app'):
        upload_dir = '/app/uploads'
        output_dir = '/app/output'
    else:
        # Running locally
        backend_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(backend_dir)
        upload_dir = os.path.join(project_root, 'uploads')
        output_dir = os.path.join(project_root, OUTPUT_FOLDER)
    
    # Collect Step 1 results
    step1_dir = os.path.join(upload_dir, 'Step_1')
    if os.path.exists(step1_dir):
        try:
            for file in os.listdir(step1_dir):
                if (
                    file.endswith('.DNAcopyout')
                    or file.endswith('.unionbedcv')
                    or '.DNAcopyout.up' in file
                    or '.DNAcopyout.down-' in file
                ):
                    results['step_1'].append(file)
        except Exception as e:
            print(f"Error collecting Step 1 results: {e}")
    
    # Collect output directory results
    if os.path.exists(output_dir):
        try:
            for root, dirs, files in os.walk(output_dir):
                for file in files:
                    rel_path = os.path.relpath(os.path.join(root, file), output_dir)
                    # Handle both Windows and Unix path separators
                    parts = rel_path.replace('\\', '/').split('/')
                    step = parts[0] if parts else 'general'
                    if step.startswith('Step_'):
                        step_num = step.replace('Step_', 'step_')
                        if step_num not in results:
                            results[step_num] = []
                        results[step_num].append(rel_path.replace('\\', '/'))
        except Exception as e:
            print(f"Error collecting output results: {e}")
    
    pipeline_status['results'] = results


# API Routes

@app.route('/api/status', methods=['GET'])
def get_status():
    """Get current pipeline status"""
    return jsonify(pipeline_status)


@app.route('/api/pipeline-reset', methods=['POST'])
@app.route('/api/reset-pipeline', methods=['POST'])
def reset_pipeline_state():
    """Clear stuck 'running' status so you can click Run again. Does not stop Docker jobs already started on the host."""
    global pipeline_status, pipeline_run_thread
    pipeline_run_thread = None
    pipeline_status = {
        'status': 'idle',
        'current_step': None,
        'progress': 0,
        'message': 'Status reset — you can start a new run.',
        'start_time': None,
        'end_time': None,
        'results': {},
    }
    return jsonify({'message': 'Pipeline status reset to idle', 'status': pipeline_status})


@app.route('/api/upload', methods=['POST'])
def upload_file():
    """Handle file upload"""
    print(f"Upload request received. Files: {list(request.files.keys())}")
    
    if 'file' not in request.files:
        print("ERROR: No 'file' in request.files")
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    data_type = request.form.get('data_type', 'bam')  # fastq, bam, or vcf
    
    print(f"Uploading file: {file.filename}, data_type: {data_type}")
    
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    if not allowed_file(file.filename):
        return jsonify({'error': f'File type not allowed. Allowed: {ALLOWED_EXTENSIONS}'}), 400
    
    # Inside Docker container, uploads are at /app/uploads
    if os.path.exists('/app'):
        upload_base = '/app/uploads/data'
    else:
        # Running locally
        backend_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(backend_dir)
        upload_base = os.path.join(project_root, 'uploads', 'data')
    
    # Determine upload directory based on data type
    if data_type == 'fastq':
        upload_path = os.path.join(upload_base, 'fastq')
    elif data_type == 'bam':
        upload_path = os.path.join(upload_base, 'bams')
    elif data_type == 'vcf':
        upload_path = os.path.join(upload_base, 'vcfs')
    else:
        return jsonify({'error': f'Invalid data type: {data_type}'}), 400
    
    # Ensure directory exists
    os.makedirs(upload_path, exist_ok=True)
    print(f"Upload path: {upload_path}")
    
    filename = secure_filename(file.filename)
    filepath = os.path.join(upload_path, filename)
    
    try:
        # Larger buffer speeds big FASTQ/BAM saves (Docker Desktop bind mounts can be slow).
        with open(filepath, 'wb') as out:
            shutil.copyfileobj(file.stream, out, length=8 * 1024 * 1024)
        file_size = os.path.getsize(filepath)
        print(f"File saved successfully: {filepath}, size: {file_size} bytes")
        
        return jsonify({
            'message': 'File uploaded successfully',
            'filename': filename,
            'data_type': data_type,
            'size': file_size
        })
    except Exception as e:
        print(f"ERROR saving file: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Upload failed: {str(e)}'}), 500


@app.route('/api/files', methods=['GET'])
def list_files():
    """List uploaded files"""
    data_type = request.args.get('data_type', None)
    
    # Inside Docker container, uploads are at /app/uploads
    if os.path.exists('/app'):
        upload_base = '/app/uploads/data'
    else:
        # Running locally
        backend_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(backend_dir)
        upload_base = os.path.join(project_root, 'uploads', 'data')
    
    files = {
        'fastq': [],
        'bam': [],
        'vcf': []
    }
    
    for dtype in ['fastq', 'bam', 'vcf']:
        if data_type and data_type != dtype:
            continue
        
        if dtype == 'bam':
            dir_path = os.path.join(upload_base, 'bams')
        else:
            dir_path = os.path.join(upload_base, f'{dtype}s')
        
        if os.path.exists(dir_path):
            try:
                files[dtype] = [f for f in os.listdir(dir_path) 
                               if os.path.isfile(os.path.join(dir_path, f))]
            except Exception as e:
                print(f"Error listing files in {dir_path}: {e}")
    
    return jsonify(files)


@app.route('/api/files/<data_type>/<filename>', methods=['DELETE'])
def delete_file(data_type, filename):
    """Delete an uploaded file"""
    # Decode filename (handle URL encoding)
    from urllib.parse import unquote
    filename = unquote(filename)
    
    # Inside Docker container, uploads are at /app/uploads
    if os.path.exists('/app'):
        upload_base = '/app/uploads/data'
    else:
        # Running locally
        backend_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(backend_dir)
        upload_base = os.path.join(project_root, 'uploads', 'data')
    
    # Determine upload directory based on data type
    if data_type == 'fastq':
        upload_path = os.path.join(upload_base, 'fastq')
    elif data_type == 'bam':
        upload_path = os.path.join(upload_base, 'bams')
    elif data_type == 'vcf':
        upload_path = os.path.join(upload_base, 'vcfs')
    else:
        return jsonify({'error': 'Invalid data type'}), 400
    
    filepath = os.path.join(upload_path, filename)
    
    # Security check - ensure filename doesn't contain path traversal
    if not os.path.abspath(filepath).startswith(os.path.abspath(upload_path)):
        return jsonify({'error': 'Invalid file path'}), 400
    
    if not os.path.exists(filepath):
        return jsonify({'error': 'File not found'}), 404
    
    try:
        os.remove(filepath)
        # Also remove index file if it's a BAM file
        if data_type == 'bam' and os.path.exists(filepath + '.bai'):
            os.remove(filepath + '.bai')
        return jsonify({'message': 'File deleted successfully'})
    except Exception as e:
        return jsonify({'error': f'Failed to delete file: {str(e)}'}), 500


@app.route('/api/run', methods=['POST'])
def run_pipeline():
    """Start pipeline execution"""
    global pipeline_status, pipeline_run_data_type, pipeline_adjustment_coefficient, pipeline_run_thread

    # silent=True: Flask returns 400 on malformed JSON if silent=False
    data = request.get_json(silent=True) or {}

    raw_ac = data.get('adjustment_coefficient', 1.0)
    try:
        adjustment_coefficient = float(raw_ac if raw_ac is not None else 1.0)
    except (TypeError, ValueError):
        adjustment_coefficient = 1.0
    if adjustment_coefficient != adjustment_coefficient:  # NaN
        adjustment_coefficient = 1.0

    force_restart = bool(data.get('force_restart'))

    if pipeline_status['status'] == 'running':
        thread_dead = pipeline_run_thread is None or not pipeline_run_thread.is_alive()
        if force_restart or thread_dead:
            pipeline_run_thread = None
            # fall through — reset status and start a new run
        else:
            return jsonify({
                'error': 'Pipeline is already running',
                'hint': 'Wait for it to finish, or refresh the page if the UI is stuck.',
            }), 400

    # Reset status
    pipeline_status = {
        'status': 'idle',
        'current_step': None,
        'progress': 0,
        'message': '',
        'start_time': None,
        'end_time': None,
        'results': {}
    }

    pipeline_run_data_type = data.get('data_type')
    pipeline_adjustment_coefficient = adjustment_coefficient

    # Keep ADJUSTMENT_COEFFICIENT in sync with UI without wiping the rest of config.sh
    _merge_adjustment_into_config(adjustment_coefficient)

    thread = threading.Thread(target=run_pipeline_thread)
    thread.daemon = True
    pipeline_run_thread = thread
    thread.start()

    return jsonify({'message': 'Pipeline started'})


@app.route('/api/results', methods=['GET'])
def get_results():
    """Get pipeline results"""
    step = request.args.get('step', None)
    
    if step:
        # Return specific step results
        step_dir = f'uploads/Step_{step}'
        if os.path.exists(step_dir):
            files = [f for f in os.listdir(step_dir) if os.path.isfile(os.path.join(step_dir, f))]
            return jsonify({'files': files})
        return jsonify({'files': []})
    
    # Return all results
    return jsonify(pipeline_status.get('results', {}))


@app.route('/api/download/<step>/<filename>', methods=['GET'])
def download_file(step, filename):
    """Download a result file"""
    # Inside Docker container, uploads are at /app/uploads
    if os.path.exists('/app'):
        filepath = os.path.join('/app', 'uploads', f'Step_{step}', filename)
    else:
        # Running locally
        backend_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(backend_dir)
        filepath = os.path.join(project_root, 'uploads', f'Step_{step}', filename)
    
    if os.path.exists(filepath):
        return send_file(filepath, as_attachment=True)
    return jsonify({'error': 'File not found'}), 404


@app.route('/api/download-all', methods=['GET'])
def download_all():
    """Download all results as a zip file"""
    zip_path = 'output/all_results.zip'
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Add Step outputs
        for step in [0, 1, 2, 3]:
            step_dir = f'uploads/Step_{step}'
            if os.path.exists(step_dir):
                for root, dirs, files in os.walk(step_dir):
                    for file in files:
                        filepath = os.path.join(root, file)
                        arcname = os.path.join(f'Step_{step}', os.path.relpath(filepath, step_dir))
                        zipf.write(filepath, arcname)
        
        # Add output directory
        if os.path.exists(OUTPUT_FOLDER):
            for root, dirs, files in os.walk(OUTPUT_FOLDER):
                for file in files:
                    filepath = os.path.join(root, file)
                    arcname = os.path.join('output', os.path.relpath(filepath, OUTPUT_FOLDER))
                    zipf.write(filepath, arcname)
    
    return send_file(zip_path, as_attachment=True, download_name='sexfindr_results.zip')


@app.route('/api/clear', methods=['POST'])
def clear_data():
    """Clear uploaded files and reset pipeline"""
    global pipeline_status
    
    try:
        # Inside Docker container, uploads are at /app/uploads
        if os.path.exists('/app'):
            upload_base = '/app/uploads/data'
        else:
            # Running locally
            backend_dir = os.path.dirname(os.path.abspath(__file__))
            project_root = os.path.dirname(backend_dir)
            upload_base = os.path.join(project_root, 'uploads', 'data')
        
        # Clear uploads
        for dtype in ['fastq', 'bam', 'vcf']:
            if dtype == 'bam':
                dir_path = os.path.join(upload_base, 'bams')
            else:
                dir_path = os.path.join(upload_base, f'{dtype}s')
            
            if os.path.exists(dir_path):
                try:
                    for file in os.listdir(dir_path):
                        filepath = os.path.join(dir_path, file)
                        if os.path.isfile(filepath):
                            os.remove(filepath)
                except Exception as e:
                    print(f"Error clearing {dir_path}: {e}")
        
        # Reset status
        pipeline_status = {
            'status': 'idle',
            'current_step': None,
            'progress': 0,
            'message': '',
            'start_time': None,
            'end_time': None,
            'results': {}
        }
        
        return jsonify({'message': 'Data cleared successfully'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


PIPELINE_PATHS_KEYS = ('reference_genome_path', 'bowtie2_index_path')


def _get_uploads_dir():
    """Return uploads directory (for use from any context)."""
    if os.path.exists('/app'):
        return '/app/uploads'
    backend_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(backend_dir)
    return os.path.join(project_root, 'uploads')


def _merge_adjustment_into_config(adjustment_coefficient):
    """Update ADJUSTMENT_COEFFICIENT in uploads/config.sh without wiping other keys (paths, thresholds)."""
    config_path = os.path.join(_get_uploads_dir(), 'config.sh')
    line = f'ADJUSTMENT_COEFFICIENT={adjustment_coefficient}\n'
    if os.path.exists(config_path):
        with open(config_path, 'r', encoding='utf-8') as f:
            data = f.read()
        if re.search(r'(?m)^ADJUSTMENT_COEFFICIENT=', data):
            data = re.sub(r'(?m)^ADJUSTMENT_COEFFICIENT=.*\n?', line, data)
        else:
            data = data.rstrip() + '\n' + line
    else:
        data = '#!/bin/bash\n' + line
    with open(config_path, 'w', encoding='utf-8') as f:
        f.write(data)


def _get_pipeline_paths_file():
    return os.path.join(_get_uploads_dir(), 'pipeline_paths.json')


def load_pipeline_paths():
    """Load pipeline paths from uploads. Returns dict with keys in PIPELINE_PATHS_KEYS; missing keys are ''."""
    path = _get_pipeline_paths_file()
    out = {k: '' for k in PIPELINE_PATHS_KEYS}
    if not os.path.exists(path):
        return out
    try:
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        for k in PIPELINE_PATHS_KEYS:
            if k in data and data[k]:
                out[k] = sanitize_user_host_path(data[k])
    except Exception as e:
        print(f"Error loading pipeline_paths.json: {e}")
    return out


def save_pipeline_paths(data):
    """Save pipeline paths to uploads. Only updates keys present in data."""
    path = _get_pipeline_paths_file()
    current = load_pipeline_paths()
    for k in PIPELINE_PATHS_KEYS:
        if k in data and data[k] is not None:
            current[k] = sanitize_user_host_path(data[k])
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(current, f, indent=2)
    return current


@app.route('/api/pipeline-paths', methods=['GET'])
def get_pipeline_paths():
    """Get pipeline paths (reference genome, bowtie2 index) set by the user in the frontend."""
    return jsonify(load_pipeline_paths())


@app.route('/api/pipeline-paths', methods=['POST'])
def post_pipeline_paths():
    """Save pipeline paths from the frontend. All paths are user-provided; no hardcoded backend paths."""
    data = request.get_json() or {}
    try:
        saved = save_pipeline_paths(data)
        return jsonify(saved)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/sample-lists', methods=['GET'])
def get_sample_lists():
    """Get sample lists (male and female)"""
    # Inside Docker container, uploads are at /app/uploads
    if os.path.exists('/app'):
        step0_dir = '/app/uploads/Step_0'
    else:
        # Running locally
        backend_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(backend_dir)
        step0_dir = os.path.join(project_root, 'uploads', 'Step_0')
    
    male_samples_file = os.path.join(step0_dir, 'male_samples.txt')
    female_samples_file = os.path.join(step0_dir, 'female_samples.txt')
    
    male_samples = ''
    female_samples = ''
    
    # Read male samples
    if os.path.exists(male_samples_file):
        try:
            with open(male_samples_file, 'r', encoding='utf-8') as f:
                male_samples = f.read().strip()
        except Exception as e:
            print(f"Error reading male_samples.txt: {e}")
    
    # Read female samples
    if os.path.exists(female_samples_file):
        try:
            with open(female_samples_file, 'r', encoding='utf-8') as f:
                female_samples = f.read().strip()
        except Exception as e:
            print(f"Error reading female_samples.txt: {e}")
    
    return jsonify({
        'male_samples': male_samples,
        'female_samples': female_samples
    })


def _count_sample_lines(text):
    return len([l for l in (text or '').split('\n') if l.strip() and not l.strip().startswith('#')])


@app.route('/api/sample-lists', methods=['POST'])
def save_sample_lists():
    """Save sample lists (male and female). Only overwrite a file when that list is non-empty;
    this prevents clearing the other list when the user only fills one box and clicks Save."""
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    male_samples = (data.get('male_samples') or '').strip().replace('\r\n', '\n').replace('\r', '\n')
    female_samples = (data.get('female_samples') or '').strip().replace('\r\n', '\n').replace('\r', '\n')
    
    # Inside Docker container, uploads are at /app/uploads
    if os.path.exists('/app'):
        step0_dir = '/app/uploads/Step_0'
    else:
        # Running locally
        backend_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(backend_dir)
        step0_dir = os.path.join(project_root, 'uploads', 'Step_0')
    
    # Ensure directory exists
    os.makedirs(step0_dir, exist_ok=True)
    
    male_samples_file = os.path.join(step0_dir, 'male_samples.txt')
    female_samples_file = os.path.join(step0_dir, 'female_samples.txt')
    
    try:
        # Only overwrite a file when we have non-empty content for it (keeps the other list from disappearing)
        if male_samples:
            with open(male_samples_file, 'w', encoding='utf-8') as f:
                f.write(male_samples)
        if female_samples:
            with open(female_samples_file, 'w', encoding='utf-8') as f:
                f.write(female_samples)
        
        # Count what's in the files after save (read back if we didn't overwrite)
        if male_samples:
            male_count = _count_sample_lines(male_samples)
        elif os.path.exists(male_samples_file):
            with open(male_samples_file, 'r', encoding='utf-8') as f:
                male_count = _count_sample_lines(f.read())
        else:
            male_count = 0
        if female_samples:
            female_count = _count_sample_lines(female_samples)
        elif os.path.exists(female_samples_file):
            with open(female_samples_file, 'r', encoding='utf-8') as f:
                female_count = _count_sample_lines(f.read())
        else:
            female_count = 0
        
        return jsonify({
            'message': 'Sample lists saved successfully',
            'male_samples_count': male_count,
            'female_samples_count': female_count
        })
    except Exception as e:
        return jsonify({'error': f'Failed to save sample lists: {str(e)}'}), 500


@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    # Check if Docker is available
    try:
        result = subprocess.run(['docker', 'ps'], capture_output=True, timeout=5)
        docker_available = result.returncode == 0
    except:
        docker_available = False
    
    # Check if Docker image exists
    try:
        result = subprocess.run(['docker', 'images', 'sexfindr:latest'], capture_output=True, timeout=5)
        image_exists = 'sexfindr' in result.stdout.decode()
    except:
        image_exists = False
    
    return jsonify({
        'status': 'ok',
        'docker_available': docker_available,
        'docker_image_exists': image_exists
    })


if __name__ == '__main__':
    print("Starting SexFindR Web Interface Backend...")
    print("API will be available at http://localhost:5000")
    app.run(host='0.0.0.0', port=5000, debug=True)

