#!/bin/bash
# Quick start script for SexFindR Web Interface

echo "=========================================="
echo "SexFindR Web Interface - Quick Start"
echo "=========================================="
echo ""

# Check if Docker is running
if ! docker ps >/dev/null 2>&1; then
    echo "ERROR: Docker is not running!"
    echo "Please start Docker Desktop and try again."
    exit 1
fi

# Check if sexfindr image exists
if ! docker images sexfindr:latest | grep -q sexfindr; then
    echo "WARNING: sexfindr:latest image not found!"
    echo "Please load the Docker image first:"
    echo "  docker load -i ../sexfindr_image.tar"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Start services
echo "Starting web interface..."
docker-compose up -d

echo ""
echo "=========================================="
echo "Web Interface Started!"
echo "=========================================="
echo ""
echo "Access the interface at:"
echo "  http://localhost"
echo ""
echo "Backend API at:"
echo "  http://localhost:5000"
echo ""
echo "To stop the interface:"
echo "  docker-compose down"
echo ""




