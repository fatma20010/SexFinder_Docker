# SexFindR Web Interface

A professional, user-friendly web interface for the SexFindR pipeline. This interface allows users to upload data, configure parameters, run the pipeline, and download results through an intuitive web browser.

## Features

- 🎨 **Modern UI**: Clean, professional interface built with modern web technologies
- 📤 **File Upload**: Drag-and-drop file upload with support for FASTQ, BAM, and VCF files
- ⚙️ **Parameter Configuration**: Easy adjustment of pipeline parameters
- 📊 **Real-time Progress**: Live progress tracking with detailed status updates
- 📥 **Results Download**: Download individual files or all results as a zip
- 🐳 **Docker Integration**: Seamlessly runs the SexFindR pipeline using Docker

## Architecture

- **Backend**: Flask (Python) REST API
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla JS)
- **Container**: Docker and Docker Compose for deployment

## Quick Start

### Prerequisites

1. Docker and Docker Compose installed
2. SexFindR Docker image loaded (`sexfindr:latest`)

### Option 1: Using Docker Compose (Recommended)

```bash
cd web_interface
docker-compose up -d
```

The interface will be available at:
- Frontend: http://localhost
- Backend API: http://localhost:5000

### Option 2: Manual Setup

#### Backend

```bash
cd web_interface/backend
pip install -r requirements.txt
python app.py
```

#### Frontend

Serve the frontend files using any web server. For example, with Python:

```bash
cd web_interface/frontend
python -m http.server 8000
```

Then open http://localhost:8000 in your browser.

## Usage

1. **Upload Data**: Select your data type (BAM, FASTQ, or VCF) and upload files
2. **Configure**: Set the adjustment coefficient (default: 1.0)
3. **Run**: Click "Start Pipeline" to begin analysis
4. **Monitor**: Watch real-time progress and status updates
5. **Download**: Get your results when the pipeline completes

## API Endpoints

- `GET /api/status` - Get pipeline status
- `POST /api/upload` - Upload files
- `GET /api/files` - List uploaded files
- `POST /api/run` - Start pipeline
- `GET /api/results` - Get results
- `GET /api/download/<step>/<filename>` - Download a file
- `GET /api/download-all` - Download all results as zip
- `POST /api/clear` - Clear uploaded data
- `GET /api/health` - System health check

## Project Structure

```
web_interface/
├── backend/
│   ├── app.py              # Flask backend
│   ├── requirements.txt     # Python dependencies
│   └── Dockerfile          # Backend container
├── frontend/
│   ├── index.html          # Main HTML
│   ├── styles.css          # Styling
│   ├── app.js              # Frontend logic
│   └── Dockerfile          # Frontend container
├── docker-compose.yml      # Orchestration
└── README.md              # This file
```

## Configuration

The backend automatically creates a minimal `config.sh` file. You can customize it by modifying the `run_pipeline_thread()` function in `backend/app.py`.

## Troubleshooting

### Docker not available
- Ensure Docker Desktop is running
- Check that the `sexfindr:latest` image exists: `docker images | grep sexfindr`

### Port conflicts
- Change ports in `docker-compose.yml` if 80 or 5000 are in use
- Update frontend API_BASE in `frontend/app.js` if backend port changes

### File upload issues
- Check file size limits (default: 10GB)
- Ensure file extensions are allowed (.bam, .fastq, .fq, .vcf, .gz)

## Development

### Backend Development

```bash
cd backend
pip install -r requirements.txt
export FLASK_ENV=development
python app.py
```

### Frontend Development

Edit files in `frontend/` and refresh the browser. No build step required.

## Security Notes

- This is designed for local/trusted network use
- For production deployment, add authentication and HTTPS
- File uploads are stored in `uploads/` directory
- Consider adding file size limits and validation

## License

Same as the main SexFindR project.

## Support

For issues or questions:
- Check the main SexFindR documentation
- Review API responses in browser developer console
- Check Docker logs: `docker-compose logs`




