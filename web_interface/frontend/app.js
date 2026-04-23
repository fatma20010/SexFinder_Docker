// SexFindR Web Interface - Frontend JavaScript

// Same-origin /api (nginx proxies to Flask). Works for localhost, a domain, or a cloud VM IP.
// Override before this script loads: window.__SEXFINDR_API_BASE__ = 'https://api.example.com/api';
const API_BASE = (typeof window !== 'undefined' && window.__SEXFINDR_API_BASE__ != null && window.__SEXFINDR_API_BASE__ !== '')
    ? String(window.__SEXFINDR_API_BASE__).replace(/\/$/, '')
    : `${window.location.origin}/api`.replace(/\/$/, '');

// State
let uploadedFiles = [];
let statusCheckInterval = null;

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    initializeEventListeners();
    checkSystemHealth();
    startStatusPolling();
    // Load existing files, sample lists, and pipeline paths on page load
    refreshFileList();
    loadPipelinePaths();
    const dataType = document.querySelector('input[name="dataType"]:checked').value;
    if (dataType === 'fastq') {
        loadSampleLists();
        document.getElementById('pipelinePathsSection').style.display = 'block';
    }
});

// Event Listeners
function initializeEventListeners() {
    // File upload
    const fileInput = document.getElementById('fileInput');
    const uploadArea = document.getElementById('uploadArea');
    
    fileInput.addEventListener('change', handleFileSelect);
    
    // Drag and drop
    uploadArea.addEventListener('dragover', (e) => {
        e.preventDefault();
        uploadArea.classList.add('dragover');
    });
    
    uploadArea.addEventListener('dragleave', () => {
        uploadArea.classList.remove('dragover');
    });
    
    uploadArea.addEventListener('drop', (e) => {
        e.preventDefault();
        uploadArea.classList.remove('dragover');
        const files = Array.from(e.dataTransfer.files);
        handleFiles(files);
    });
    
    // Data type selector - show/hide sample lists and pipeline paths
    document.querySelectorAll('input[name="dataType"]').forEach(radio => {
        radio.addEventListener('change', async () => {
            const dataType = radio.value;
            const sampleListsSection = document.getElementById('sampleListsSection');
            const pipelinePathsSection = document.getElementById('pipelinePathsSection');
            if (dataType === 'fastq') {
                sampleListsSection.style.display = 'block';
                pipelinePathsSection.style.display = 'block';
                await loadSampleLists();
                await loadPipelinePaths();
            } else {
                sampleListsSection.style.display = 'none';
                pipelinePathsSection.style.display = 'none';
            }
            await refreshFileList();
            checkRunButtonState();
        });
    });
    
    // Check initial state
    const initialDataType = document.querySelector('input[name="dataType"]:checked').value;
    if (initialDataType === 'fastq') {
        const sampleListsSection = document.getElementById('sampleListsSection');
        const pipelinePathsSection = document.getElementById('pipelinePathsSection');
        if (sampleListsSection) sampleListsSection.style.display = 'block';
        if (pipelinePathsSection) pipelinePathsSection.style.display = 'block';
        loadSampleLists();
    }

    // Pipeline paths
    document.getElementById('savePipelinePathsButton').addEventListener('click', savePipelinePaths);

    // Sample lists buttons
    document.getElementById('saveSampleListsButton').addEventListener('click', saveSampleLists);
    document.getElementById('loadSampleListsButton').addEventListener('click', loadSampleLists);
    
    // File input for loading sample lists from computer
    const loadSampleListsFileInput = document.getElementById('loadSampleListsFileInput');
    if (loadSampleListsFileInput) {
        loadSampleListsFileInput.addEventListener('change', handleLoadSampleListsFromFile);
    }
    
    // Update run button when sample lists change
    const maleSamples = document.getElementById('maleSamples');
    const femaleSamples = document.getElementById('femaleSamples');
    if (maleSamples) {
        maleSamples.addEventListener('input', checkRunButtonState);
    }
    if (femaleSamples) {
        femaleSamples.addEventListener('input', checkRunButtonState);
    }
    
    // Run button
    document.getElementById('runButton').addEventListener('click', runPipeline);
    
    // Download all
    document.getElementById('downloadAllButton').addEventListener('click', downloadAllResults);
    
    // Clear data
    document.getElementById('clearDataLink').addEventListener('click', (e) => {
        e.preventDefault();
        clearData();
    });
    
    // Health check
    document.getElementById('healthCheckLink').addEventListener('click', (e) => {
        e.preventDefault();
        checkSystemHealth();
    });

    const resetPipelineLink = document.getElementById('resetPipelineStatusLink');
    if (resetPipelineLink) {
        resetPipelineLink.addEventListener('click', async (e) => {
            e.preventDefault();
            if (!confirm('Reset pipeline status to idle? Use this if the UI shows Running but nothing is happening.')) {
                return;
            }
            try {
                const response = await fetch(`${API_BASE}/pipeline-reset`, { method: 'POST' });
                const data = await response.json().catch(() => ({}));
                if (response.ok) {
                    showToast(data.message || 'Status reset', 'success');
                    updateStatusDisplay({ status: 'idle', message: '', current_step: null, progress: 0 });
                    const progressSection = document.getElementById('progressSection');
                    if (progressSection) progressSection.style.display = 'none';
                    const button = document.getElementById('runButton');
                    if (button) {
                        button.disabled = false;
                        button.textContent = 'Start Pipeline';
                    }
                    stopStatusPolling();
                    startStatusPolling();
                    checkRunButtonState();
                } else {
                    showToast(data.error || 'Reset failed', 'error');
                }
            } catch (err) {
                showToast('Reset error: ' + err.message, 'error');
            }
        });
    }
}

/** Avoid sending FASTQ to data/bams (or BAM to fastq) — folder is chosen from the selected radio. */
function validateFileForDataType(file, dataType) {
    const n = file.name.toLowerCase();
    if (dataType === 'bam') {
        if (
            n.endsWith('.fastq') || n.endsWith('.fq') ||
            n.endsWith('.fastq.gz') || n.endsWith('.fq.gz')
        ) {
            return {
                ok: false,
                msg: 'This is FASTQ. Select "FASTQ Files" before upload so files go to the fastq folder (Step 0). BAM mode only accepts .bam.'
            };
        }
    }
    if (dataType === 'fastq') {
        if (n.endsWith('.bam')) {
            return {
                ok: false,
                msg: 'This is BAM. Select "BAM Files" for Step 1, or use FASTQ + Step 0 for mapping.'
            };
        }
    }
    if (dataType === 'vcf') {
        if (!(n.endsWith('.vcf') || n.endsWith('.vcf.gz'))) {
            return { ok: false, msg: 'VCF mode expects .vcf or .vcf.gz files.' };
        }
    }
    return { ok: true };
}

// File Handling
function handleFileSelect(e) {
    const files = Array.from(e.target.files);
    handleFiles(files);
}

async function handleFiles(files) {
    const dataType = document.querySelector('input[name="dataType"]:checked').value;

    for (const file of files) {
        await uploadFile(file, dataType);
    }

    updateUploadedFilesDisplay();
    checkRunButtonState();
}

async function refreshFileList() {
    try {
        console.log('Refreshing file list from server...');
        const response = await fetch(`${API_BASE}/files`);
        const files = await response.json();
        console.log('Files from server:', files);
        
        // Get current data type to filter
        const dataType = document.querySelector('input[name="dataType"]:checked')?.value;
        if (!dataType) {
            console.error('No data type selected when refreshing file list');
            return;
        }
        
        // Get files from server for current data type
        const serverFiles = [];
        if (dataType === 'bam' && files.bam && files.bam.length > 0) {
            files.bam.forEach(name => {
                serverFiles.push({ name, type: 'bam', uploaded: true });
            });
        }
        if (dataType === 'fastq' && files.fastq && files.fastq.length > 0) {
            files.fastq.forEach(name => {
                serverFiles.push({ name, type: 'fastq', uploaded: true });
            });
        }
        if (dataType === 'vcf' && files.vcf && files.vcf.length > 0) {
            files.vcf.forEach(name => {
                serverFiles.push({ name, type: 'vcf', uploaded: true });
            });
        }
        
        // Merge with existing files - preserve size info and other metadata
        const existingFileMap = new Map();
        uploadedFiles.forEach(file => {
            if (file.type === dataType) {
                existingFileMap.set(file.name, file);
            }
        });
        
        // Update or add files from server
        serverFiles.forEach(serverFile => {
            const existing = existingFileMap.get(serverFile.name);
            if (existing) {
                // Keep existing metadata (size, etc.)
                existing.uploaded = true;
            } else {
                // New file from server
                existingFileMap.set(serverFile.name, serverFile);
            }
        });
        
        // Convert back to array, keeping only files matching current data type
        uploadedFiles = Array.from(existingFileMap.values());
        
        console.log('Updated uploadedFiles array:', uploadedFiles.length, 'files');
        updateUploadedFilesDisplay();
        checkRunButtonState(); // Update button state after refresh
    } catch (error) {
        console.error('Error refreshing file list:', error);
    }
}

function setUploadProgress(visible, pct, label) {
    const wrap = document.getElementById('uploadProgressWrap');
    const bar = document.getElementById('uploadProgressBar');
    const text = document.getElementById('uploadProgressText');
    if (!wrap || !bar || !text) return;
    if (!visible) {
        wrap.style.display = 'none';
        return;
    }
    wrap.style.display = 'block';
    bar.style.width = `${Math.min(100, Math.max(0, pct))}%`;
    text.textContent = label || '';
}

/**
 * Large FASTQ/BAM uploads are limited by disk + Docker volume speed; XHR gives real progress (no fake 1s delay).
 */
function uploadFileXhr(file, dataType) {
    return new Promise((resolve, reject) => {
        const formData = new FormData();
        formData.append('file', file);
        formData.append('data_type', dataType);

        const xhr = new XMLHttpRequest();
        xhr.open('POST', `${API_BASE}/upload`);
        xhr.upload.addEventListener('progress', (e) => {
            if (e.lengthComputable) {
                const pct = (e.loaded / e.total) * 100;
                setUploadProgress(true, pct, `${file.name} — ${Math.round(pct)}% (${formatFileSize(e.loaded)} / ${formatFileSize(e.total)})`);
            } else {
                setUploadProgress(true, 0, `${file.name} — uploading… ${formatFileSize(e.loaded)}`);
            }
        });
        xhr.onload = () => {
            let result = {};
            try {
                result = JSON.parse(xhr.responseText || '{}');
            } catch (_) { /* ignore */ }
            if (xhr.status >= 200 && xhr.status < 300) {
                resolve(result);
            } else {
                reject(new Error(result.error || `Upload failed (${xhr.status})`));
            }
        };
        xhr.onerror = () => reject(new Error('Network error during upload'));
        xhr.send(formData);
    });
}

async function uploadFile(file, dataType) {
    console.log('Uploading file:', file.name, 'Type:', dataType);

    const typeCheck = validateFileForDataType(file, dataType);
    if (!typeCheck.ok) {
        showToast(typeCheck.msg, 'error');
        return;
    }

    try {
        showToast(`Starting upload: ${file.name}`, 'success');
        setUploadProgress(true, 0, `${file.name} — starting…`);

        const result = await uploadFileXhr(file, dataType);
        console.log('Upload response:', result);

        const existingIndex = uploadedFiles.findIndex(f => f.name === file.name && f.type === dataType);
        if (existingIndex === -1) {
            uploadedFiles.push({
                name: file.name,
                size: file.size || result.size || 0,
                type: dataType,
                uploaded: true
            });
        } else {
            uploadedFiles[existingIndex].size = file.size || result.size || 0;
        }

        setUploadProgress(false);
        showToast(`✓ File uploaded: ${file.name}`, 'success');
        updateUploadedFilesDisplay();

        const uploadedFilesContainer = document.getElementById('uploadedFiles');
        if (uploadedFilesContainer) {
            uploadedFilesContainer.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
        checkRunButtonState();
    } catch (error) {
        console.error('Upload error:', error);
        setUploadProgress(false);
        showToast(`Upload error: ${error.message}`, 'error');
    }
}

function updateUploadedFilesDisplay() {
    const container = document.getElementById('uploadedFiles');
    
    if (!container) {
        console.error('uploadedFiles container not found');
        return;
    }
    
    // Always show the container, even if empty
    container.style.display = 'block';
    container.style.marginTop = '1.5rem';
    container.style.padding = '1rem';
    container.style.background = 'var(--bg-color)';
    container.style.borderRadius = '8px';
    
    if (uploadedFiles.length === 0) {
        container.innerHTML = '<p style="color: var(--text-secondary); font-style: italic;">No files uploaded yet</p>';
        return;
    }
    
    let html = '<h3 style="margin-bottom: 1rem; color: var(--text-primary);">Uploaded Files (' + uploadedFiles.length + ')</h3>';
    
    uploadedFiles.forEach((file, index) => {
        html += `
            <div class="file-item">
            <div class="file-item-info">
                <div class="file-icon">${file.type.toUpperCase()}</div>
                <div>
                    <div class="file-name">${file.name}</div>
                    <div class="file-size">${file.size ? formatFileSize(file.size) : 'Size unknown'}</div>
                </div>
            </div>
            <button class="remove-file" onclick="removeFile(${index})" title="Remove this file">Remove</button>
            </div>
        `;
    });
    
    container.innerHTML = html;
    console.log('Updated file display. Files:', uploadedFiles.length);
}

async function removeFile(index) {
    const file = uploadedFiles[index];
    
    if (!confirm(`Are you sure you want to remove ${file.name}?`)) {
        return;
    }
    
    try {
        // Delete file from server
        const response = await fetch(`${API_BASE}/files/${file.type}/${encodeURIComponent(file.name)}`, {
            method: 'DELETE'
        });
        
        const result = await response.json();
        
        if (response.ok) {
            // Remove from local array
            uploadedFiles.splice(index, 1);
            updateUploadedFilesDisplay();
            checkRunButtonState();
            showToast(`File removed: ${file.name}`, 'success');
        } else {
            showToast(result.error || 'Failed to remove file', 'error');
        }
    } catch (error) {
        // Even if server delete fails, remove from UI
        uploadedFiles.splice(index, 1);
        updateUploadedFilesDisplay();
        checkRunButtonState();
        showToast('File removed from list (server delete may have failed)', 'warning');
    }
}

function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
}

// Pipeline Execution
async function runPipeline() {
    const button = document.getElementById('runButton');
    const progressSection = document.getElementById('progressSection');
    
    button.disabled = true;
    button.textContent = 'Running...';
    progressSection.style.display = 'block';
    
    let adjustmentCoefficient = parseFloat(String(document.getElementById('adjustmentCoefficient').value).trim());
    if (!Number.isFinite(adjustmentCoefficient)) {
        adjustmentCoefficient = 1.0;
    }
    const dataType = document.querySelector('input[name="dataType"]:checked')?.value || 'bam';
    
    try {
        const response = await fetch(`${API_BASE}/run`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                adjustment_coefficient: adjustmentCoefficient,
                data_type: dataType
            })
        });
        
        const result = await response.json().catch(() => ({}));
        
        if (response.ok) {
            showToast('Pipeline started successfully', 'success');
            // First run stops polling on completion; restart so subsequent runs show progress
            stopStatusPolling();
            startStatusPolling();
        } else {
            const errMsg = result.error || 'Failed to start pipeline';
            const hint = result.hint ? ` ${result.hint}` : '';
            showToast(errMsg + hint, 'error');
            button.disabled = false;
            button.textContent = 'Start Pipeline';
        }
    } catch (error) {
        showToast('Error: ' + error.message, 'error');
        button.disabled = false;
        button.textContent = 'Start Pipeline';
    }
}

// Status Polling
function startStatusPolling() {
    statusCheckInterval = setInterval(updateStatus, 2000);
    updateStatus();
}

function stopStatusPolling() {
    if (statusCheckInterval) {
        clearInterval(statusCheckInterval);
        statusCheckInterval = null;
    }
}

async function updateStatus() {
    try {
        const response = await fetch(`${API_BASE}/status`);
        const status = await response.json();
        
        updateStatusDisplay(status);
        updateProgress(status);
        
        if (status.status === 'completed' || status.status === 'error') {
            if (status.status === 'completed') {
                loadResults();
            }
            stopStatusPolling();
            const button = document.getElementById('runButton');
            button.disabled = false;
            button.textContent = 'Run Again';
        }
    } catch (error) {
        console.error('Status check error:', error);
    }
}

function updateStatusDisplay(status) {
    const indicator = document.getElementById('statusIndicator');
    const dot = document.getElementById('statusDot');
    const text = document.getElementById('statusText');
    
    dot.className = 'status-dot';
    
    if (status.status === 'running') {
        dot.classList.add('running');
        text.textContent = 'Running';
    } else if (status.status === 'completed') {
        text.textContent = 'Completed';
    } else if (status.status === 'error') {
        dot.classList.add('error');
        text.textContent = 'Error';
    } else {
        text.textContent = 'Ready';
    }
}

function updateProgress(status) {
    const progressBar = document.getElementById('progressBar');
    const progressText = document.getElementById('progressText');
    const progressDetails = document.getElementById('progressDetails');
    
    progressBar.style.width = `${status.progress}%`;
    
    if (status.current_step) {
        let message = status.message || 'Processing...';
        
        // Add helpful information for Step 0
        if (status.current_step.includes('Step 0') || status.current_step.includes('Mapping')) {
            message += ' (This may take 30 minutes to several hours depending on file size)';
        }
        // DifCover: backend streams log lines; "stage 2" = ratio step, "stage 3" = R/DNAcopy, etc.
        if (status.current_step && status.current_step.includes('DifCover')) {
            if (/stage\s*2/i.test(message)) {
                message += ' (DifCover: computing ratios per window — can take several minutes)';
            } else if (/stage\s*3/i.test(message)) {
                message += ' (DifCover: R / DNAcopy segmentation)';
            } else if (/stage\s*[45]/i.test(message)) {
                message += ' (DifCover: thresholds & output files)';
            }
        }
        
        progressText.textContent = `${status.current_step} - ${message}`;
    } else {
        progressText.textContent = status.message || 'Waiting...';
    }
    
    if (status.start_time) {
        const start = new Date(status.start_time);
        const now = new Date();
        const elapsed = Math.floor((now - start) / 1000);
        const elapsedFormatted = formatTime(elapsed);
        
        // Add estimated time for Step 0
        let timeInfo = `Elapsed time: ${elapsedFormatted}`;
        if (status.current_step && (status.current_step.includes('Step 0') || status.current_step.includes('Mapping'))) {
            timeInfo += ' | Note: Step 0 (mapping) typically takes 30 min - 4 hours per sample';
        }
        
        progressDetails.textContent = timeInfo;
    }
}

function formatTime(seconds) {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    
    if (hours > 0) {
        return `${hours}h ${minutes}m ${secs}s`;
    } else if (minutes > 0) {
        return `${minutes}m ${secs}s`;
    } else {
        return `${secs}s`;
    }
}

// Results
async function loadResults() {
    try {
        const response = await fetch(`${API_BASE}/results`);
        const results = await response.json();
        
        displayResults(results);
    } catch (error) {
        showToast('Error loading results: ' + error.message, 'error');
    }
}

function displayResults(results) {
    const section = document.getElementById('resultsSection');
    const content = document.getElementById('resultsContent');
    
    section.style.display = 'block';
    
    if (Object.keys(results).length === 0) {
        content.innerHTML = '<p>No results available yet.</p>';
        return;
    }
    
    let html = '<div class="results-grid">';
    
    for (const [step, files] of Object.entries(results)) {
        if (files.length > 0) {
            html += `
                <div class="result-card">
                    <h3>${step.replace('_', ' ').toUpperCase()}</h3>
                    <ul class="result-file-list">
                        ${files.map(file => `
                            <li>
                                <span>${file}</span>
                                <a href="${API_BASE}/download/${step}/${file}" class="download-link" download>Download</a>
                            </li>
                        `).join('')}
                    </ul>
                </div>
            `;
        }
    }
    
    html += '</div>';
    content.innerHTML = html;
}

async function downloadAllResults() {
    try {
        window.location.href = `${API_BASE}/download-all`;
        showToast('Download started', 'success');
    } catch (error) {
        showToast('Download error: ' + error.message, 'error');
    }
}

// Utility Functions
function checkRunButtonState() {
    const button = document.getElementById('runButton');
    if (!button) {
        console.error('Run button not found!');
        return;
    }
    
    const dataType = document.querySelector('input[name="dataType"]:checked')?.value;
    if (!dataType) {
        console.error('No data type selected!');
        button.disabled = true;
        return;
    }
    
    console.log('Checking run button state. Data type:', dataType, 'Files:', uploadedFiles.length);

    // For FASTQ files, also check if sample lists are filled
    if (dataType === 'fastq') {
        const maleSamplesEl = document.getElementById('maleSamples');
        const femaleSamplesEl = document.getElementById('femaleSamples');
        let maleSamples = maleSamplesEl ? maleSamplesEl.value.trim() : '';
        let femaleSamples = femaleSamplesEl ? femaleSamplesEl.value.trim() : '';
        
        // Clean sample lists - remove comments and extract just sample IDs (not full paths)
        const cleanSampleList = (text) => {
            return text.split('\n')
                .map(line => line.trim())
                .filter(line => line && !line.startsWith('#'))
                .map(line => {
                    // Extract just the sample ID from full paths
                    // If it's a path like /path/to/sample.bam, extract "sample"
                    // If it's already just an ID, use it as is
                    if (line.includes('/') || line.includes('\\')) {
                        // It's a path - extract filename without extension
                        const parts = line.split(/[/\\]/);
                        const filename = parts[parts.length - 1];
                        // Remove extensions (.bam, .fastq, etc.)
                        return filename.replace(/\.(bam|fastq|fq|sam)(\.gz)?$/i, '');
                    }
                    // Remove extensions if present
                    return line.replace(/\.(bam|fastq|fq|sam)(\.gz)?$/i, '');
                })
                .filter(id => id.length > 0);
        };
        
        const maleIds = cleanSampleList(maleSamples);
        const femaleIds = cleanSampleList(femaleSamples);
        const refPath = document.getElementById('referenceGenomePath') ? document.getElementById('referenceGenomePath').value.trim() : '';
        const bowtie2Path = document.getElementById('bowtie2IndexPath') ? document.getElementById('bowtie2IndexPath').value.trim() : '';
        const hasPaths = !!(refPath && bowtie2Path);

        const hasFiles = uploadedFiles.length > 0;
        const hasSamples = (maleIds.length > 0 || femaleIds.length > 0);
        button.disabled = !(hasFiles && hasSamples && hasPaths);

        if (!hasFiles) {
            button.title = 'Please upload FASTQ files first';
        } else if (!hasSamples) {
            button.title = 'Please add sample IDs to the sample lists';
        } else if (!hasPaths) {
            button.title = 'Please set Reference genome path and Bowtie2 index path in the Pipeline paths section, then Save';
        } else {
            button.title = '';
        }
    } else {
        // For BAM and VCF: require at least one uploaded file of the selected type
        const hasFiles = uploadedFiles.length > 0;
        button.disabled = !hasFiles;
        
        console.log('BAM/VCF check - hasFiles:', hasFiles, 'disabled:', button.disabled);
        
        if (!hasFiles) {
            button.title = `Please upload ${dataType.toUpperCase()} files first`;
        } else {
            button.title = '';
        }
    }
}

async function clearData() {
    if (!confirm('Are you sure you want to clear all uploaded data?')) {
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE}/clear`, {
            method: 'POST'
        });
        
        const result = await response.json();
        
        if (response.ok) {
            uploadedFiles = [];
            updateUploadedFilesDisplay();
            checkRunButtonState();
            showToast('Data cleared successfully', 'success');
        } else {
            showToast(result.error || 'Failed to clear data', 'error');
        }
    } catch (error) {
        showToast('Error: ' + error.message, 'error');
    }
}

async function checkSystemHealth() {
    try {
        const response = await fetch(`${API_BASE}/health`);
        const health = await response.json();
        
        if (health.docker_available && health.docker_image_exists) {
            showToast('System ready - Docker available', 'success');
        } else if (!health.docker_available) {
            showToast('Warning: Docker is not running', 'warning');
        } else if (!health.docker_image_exists) {
            showToast('Warning: Docker image not found', 'warning');
        }
    } catch (error) {
        showToast('Cannot connect to backend', 'error');
    }
}

function showToast(message, type = 'success') {
    const container = document.getElementById('toastContainer');
    if (!container) {
        console.warn('Toast container not found');
        return;
    }
    
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    
    container.appendChild(toast);
    
    // Force reflow to trigger animation
    toast.offsetHeight;
    
    setTimeout(() => {
        toast.style.animation = 'slideIn 0.3s reverse';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// Pipeline paths (reference genome, bowtie2 index)
async function loadPipelinePaths() {
    try {
        const response = await fetch(`${API_BASE}/pipeline-paths`);
        const data = await response.json();
        const refEl = document.getElementById('referenceGenomePath');
        const bowtie2El = document.getElementById('bowtie2IndexPath');
        if (refEl) refEl.value = data.reference_genome_path || '';
        if (bowtie2El) bowtie2El.value = data.bowtie2_index_path || '';
    } catch (e) {
        console.error('Error loading pipeline paths:', e);
    }
}

async function savePipelinePaths() {
    const refEl = document.getElementById('referenceGenomePath');
    const bowtie2El = document.getElementById('bowtie2IndexPath');
    const reference_genome_path = refEl ? refEl.value.trim() : '';
    const bowtie2_index_path = bowtie2El ? bowtie2El.value.trim() : '';
    try {
        const response = await fetch(`${API_BASE}/pipeline-paths`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ reference_genome_path, bowtie2_index_path })
        });
        const result = await response.json();
        if (response.ok) {
            showToast('Pipeline paths saved. You can run the pipeline when using FASTQ.', 'success');
            checkRunButtonState();
        } else {
            showToast(result.error || 'Failed to save paths', 'error');
        }
    } catch (e) {
        showToast('Error saving pipeline paths: ' + e.message, 'error');
    }
}

// Sample Lists Management
async function handleLoadSampleListsFromFile(event) {
    const file = event.target.files[0];
    if (!file) {
        return;
    }
    
    // Check file type
    if (!file.name.endsWith('.txt')) {
        showToast('Please select a .txt file', 'error');
        return;
    }
    
    try {
        const text = await file.text();
        const lines = text.split('\n');
        
        // Try to detect if it's a single list or two lists
        // Look for common patterns: "male", "female", tabs, or commas
        const maleSamples = [];
        const femaleSamples = [];
        let currentList = null;
        let foundMaleHeader = false;
        let foundFemaleHeader = false;
        
        for (const line of lines) {
            const trimmed = line.trim();
            if (!trimmed || trimmed.startsWith('#')) {
                continue;
            }
            
            // Check for section headers (case insensitive)
            const lowerLine = trimmed.toLowerCase();
            if (lowerLine.includes('male') && !lowerLine.includes('female')) {
                currentList = 'male';
                foundMaleHeader = true;
                continue;
            }
            if (lowerLine.includes('female')) {
                currentList = 'female';
                foundFemaleHeader = true;
                continue;
            }
            
            // Check if line contains tab or comma (might be two columns)
            if (trimmed.includes('\t') || trimmed.includes(',')) {
                const parts = trimmed.split(/[\t,]/).map(p => p.trim()).filter(p => p);
                if (parts.length >= 2) {
                    // Two columns - assume first is sample ID, second might indicate sex
                    const sampleId = parts[0];
                    const sexIndicator = parts[1].toLowerCase();
                    if (sexIndicator.includes('male') || sexIndicator.includes('m')) {
                        maleSamples.push(sampleId);
                    } else if (sexIndicator.includes('female') || sexIndicator.includes('f')) {
                        femaleSamples.push(sampleId);
                    } else {
                        // Unknown - add to both or ask user
                        maleSamples.push(sampleId);
                    }
                    continue;
                }
            }
            
            // If we have a current list from header, add to it
            if (currentList === 'male') {
                maleSamples.push(trimmed);
            } else if (currentList === 'female') {
                femaleSamples.push(trimmed);
            } else {
                // No section header - check filename for hints
                const fileName = file.name.toLowerCase();
                if (fileName.includes('male') && !fileName.includes('female')) {
                    maleSamples.push(trimmed);
                } else if (fileName.includes('female')) {
                    femaleSamples.push(trimmed);
                } else {
                    // No clear indication - split evenly or add to male
                    // For now, add all to male if no female samples yet
                    if (femaleSamples.length === 0) {
                        maleSamples.push(trimmed);
                    } else {
                        // If we already have female samples, this might be more males
                        maleSamples.push(trimmed);
                    }
                }
            }
        }
        
        // Update the textareas
        const maleEl = document.getElementById('maleSamples');
        const femaleEl = document.getElementById('femaleSamples');
        
        if (maleEl) {
            maleEl.value = maleSamples.join('\n');
        }
        if (femaleEl) {
            femaleEl.value = femaleSamples.join('\n');
        }
        
        // Show feedback
        const totalSamples = maleSamples.length + femaleSamples.length;
        if (totalSamples > 0) {
            showToast(`✓ Loaded ${totalSamples} sample(s) from file: ${maleSamples.length} male, ${femaleSamples.length} female`, 'success');
            checkRunButtonState();
        } else {
            showToast('No valid sample IDs found in file', 'warning');
        }
        
        // Reset file input
        event.target.value = '';
    } catch (error) {
        console.error('Error loading sample lists from file:', error);
        showToast('Error reading file: ' + error.message, 'error');
        event.target.value = '';
    }
}

async function loadSampleLists() {
    try {
        // Show loading state
        const loadButton = document.getElementById('loadSampleListsButton');
        const originalText = loadButton.textContent;
        loadButton.disabled = true;
        loadButton.textContent = 'Loading...';
        
        // Ensure sample lists section is visible
        const sampleListsSection = document.getElementById('sampleListsSection');
        if (sampleListsSection) {
            sampleListsSection.style.display = 'block';
        }
        
        const response = await fetch(`${API_BASE}/sample-lists`);
        const data = await response.json();
        
        if (response.ok) {
            const maleEl = document.getElementById('maleSamples');
            const femaleEl = document.getElementById('femaleSamples');
            
            const maleSamples = data.male_samples || '';
            const femaleSamples = data.female_samples || '';
            
            if (maleEl) maleEl.value = maleSamples;
            if (femaleEl) femaleEl.value = femaleSamples;
            
            // Count non-empty, non-comment lines
            const maleCount = maleSamples.split('\n').filter(line => line.trim() && !line.trim().startsWith('#')).length;
            const femaleCount = femaleSamples.split('\n').filter(line => line.trim() && !line.trim().startsWith('#')).length;
            
            // Show feedback
            if (maleCount > 0 || femaleCount > 0) {
                showToast(`✓ Loaded sample lists: ${maleCount} male, ${femaleCount} female sample(s)`, 'success');
            } else {
                showToast('No existing sample lists found. You can create new ones.', 'info');
            }
            
            // Update run button state after loading
            checkRunButtonState();
        } else {
            // If files don't exist, that's okay - just show empty fields
            const maleEl = document.getElementById('maleSamples');
            const femaleEl = document.getElementById('femaleSamples');
            if (maleEl) maleEl.value = '';
            if (femaleEl) femaleEl.value = '';
            showToast('No existing sample lists found. You can create new ones.', 'info');
        }
        
        // Restore button
        loadButton.disabled = false;
        loadButton.textContent = originalText;
    } catch (error) {
        console.error('Error loading sample lists:', error);
        showToast('Error loading sample lists: ' + error.message, 'error');
        
        // Restore button
        const loadButton = document.getElementById('loadSampleListsButton');
        if (loadButton) {
            loadButton.disabled = false;
            loadButton.textContent = 'Load Existing Lists';
        }
    }
}

async function saveSampleLists() {
    const maleSamplesEl = document.getElementById('maleSamples');
    const femaleSamplesEl = document.getElementById('femaleSamples');
    let maleSamples = maleSamplesEl.value.trim();
    let femaleSamples = femaleSamplesEl.value.trim();
    
    // Clean sample lists - extract just sample IDs from paths
    const cleanSampleList = (text) => {
        return text.split('\n')
            .map(line => {
                const trimmed = line.trim();
                // Skip comments
                if (!trimmed || trimmed.startsWith('#')) {
                    return trimmed; // Keep comments as-is
                }
                // Extract just the sample ID from full paths
                if (trimmed.includes('/') || trimmed.includes('\\')) {
                    // It's a path - extract filename without extension
                    const parts = trimmed.split(/[/\\]/);
                    const filename = parts[parts.length - 1];
                    // Remove extensions (.bam, .fastq, etc.)
                    return filename.replace(/\.(bam|fastq|fq|sam)(\.gz)?$/i, '');
                }
                // Remove extensions if present
                return trimmed.replace(/\.(bam|fastq|fq|sam)(\.gz)?$/i, '');
            })
            .join('\n');
    };
    
    // Clean the sample lists
    maleSamples = cleanSampleList(maleSamples);
    femaleSamples = cleanSampleList(femaleSamples);
    
    // Update the textareas with cleaned values
    maleSamplesEl.value = maleSamples;
    femaleSamplesEl.value = femaleSamples;
    
    // Count actual sample IDs (non-comment lines)
    const countSamples = (text) => {
        return text.split('\n')
            .map(line => line.trim())
            .filter(line => line && !line.startsWith('#')).length;
    };
    
    const maleCount = countSamples(maleSamples);
    const femaleCount = countSamples(femaleSamples);
    
    if (maleCount === 0 && femaleCount === 0) {
        showToast('Please add at least one sample ID (just the sample name, not full file paths)', 'warning');
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE}/sample-lists`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                male_samples: maleSamples,
                female_samples: femaleSamples
            })
        });
        
        const result = await response.json();
        
        if (response.ok) {
            showToast(`✓ Sample lists saved: ${maleCount} male, ${femaleCount} female sample(s)`, 'success');
            checkRunButtonState();
            // Reload from server so both boxes show what's actually stored (prevents "other list disappeared" confusion)
            await loadSampleLists();
        } else {
            showToast(result.error || 'Failed to save sample lists', 'error');
        }
    } catch (error) {
        showToast('Error saving sample lists: ' + error.message, 'error');
    }
}

// Make removeFile available globally
window.removeFile = removeFile;

