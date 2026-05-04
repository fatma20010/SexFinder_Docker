# When built from web_interface (context: .), paths are relative to web_interface
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY backend/ .

# Bundle Step 0 script so it can be copied to uploads when missing (backend has no access to parent dir at runtime)
RUN mkdir -p /app/step0_template
COPY Step_0/run_step0_mapping.sh /app/step0_template/run_step0_mapping.sh
# Bundle Step 1 script so it can be copied to uploads/Step_1 when missing (mount overwrites container Step_1)
RUN mkdir -p /app/step1_template
COPY Step_1/run_difcover.sh /app/step1_template/run_difcover.sh

# Create necessary directories
RUN mkdir -p uploads/data/{fastq,bams,vcfs} uploads/Step_{0,1,2,3} output

# Expose port
EXPOSE 5000

# Gunicorn: long timeout for multi-GB FASTQ/BAM uploads via nginx (Flask dev server resets on large bodies).
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "1", "--threads", "4", "--timeout", "7200", "--graceful-timeout", "60", "app:app"]




