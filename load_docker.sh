#!/bin/bash
# Load SexFindR Docker Image (macOS/Linux)
# This script loads the Docker image so you can run the pipeline.

echo "=========================================="
echo "Loading SexFindR Docker Image"
echo "=========================================="
echo ""
echo "This will load the Docker image so you can run the pipeline."
echo "Please wait, this may take a few minutes..."
echo ""

# Check if Docker is running
if ! docker ps >/dev/null 2>&1; then
    echo "ERROR: Docker is not running!"
    echo ""
    echo "Please:"
    echo "1. Open Docker Desktop"
    echo "2. Wait until it says 'Docker is running'"
    echo "3. Run this script again"
    echo ""
    exit 1
fi

# Check if image file exists
if [ -f "sexfindr_image.tar" ]; then
    echo "Loading image from sexfindr_image.tar..."
    docker load -i sexfindr_image.tar
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to load image"
        exit 1
    fi
    echo ""
    echo "Done! Image loaded successfully."
elif [ -f "sexfindr_image.tar.gz" ]; then
    echo "Extracting and loading image..."
    gunzip -c sexfindr_image.tar.gz | docker load
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to load image"
        exit 1
    fi
    echo ""
    echo "Done! Image loaded successfully."
else
    echo "ERROR: Docker image file not found!"
    echo ""
    echo "Please make sure you have one of these files:"
    echo "  - sexfindr_image.tar"
    echo "  - sexfindr_image.tar.gz"
    echo ""
    echo "If you have the image on Docker Hub, you can pull it instead:"
    echo "  docker pull yourusername/sexfindr:latest"
    echo ""
    exit 1
fi

echo ""
echo "=========================================="
echo "Success! You can now run the pipeline."
echo "=========================================="
echo ""

