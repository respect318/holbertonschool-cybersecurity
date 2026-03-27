#!/bin/bash

# Define filenames
APP_FILE="app.py"
REQ_FILE="requirements.txt"
DOCKER_FILE="Dockerfile"
IMAGE_NAME="devstream-vulnerable:latest"

echo "Creating application files..."

# 1. Create app.py
cat <<EOF > $APP_FILE
from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return f"Hello from DevStream! DB: {os.environ.get('DB_HOST', 'unknown')}"

@app.route('/health')
def health():
    return "OK", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF
echo "  $APP_FILE: Created"

# 2. Create requirements.txt
echo "flask==3.0.0" > $REQ_FILE
echo "  $REQ_FILE: Created"

# 3. Create the vulnerable Dockerfile
cat <<EOF > $DOCKER_FILE
# DevStream's "production" Dockerfile
# DO NOT USE IN PRODUCTION (but they did...)

FROM ubuntu:latest

# Install everything we might need
RUN apt-get update && apt-get install -y \\
    python3 \\
    python3-pip \\
    curl \\
    wget \\
    vim \\
    net-tools \\
    iputils-ping \\
    gcc \\
    make \\
    sudo

# Set root password (for debugging)
RUN echo 'root:devstream123' | chpasswd

# Database credentials
ENV DB_HOST=prod-db.devstream.internal
ENV DB_USER=admin
ENV DB_PASSWORD=Sup3rS3cr3t!Pr0d

# Copy application
WORKDIR /app
COPY . /app

# Install Python dependencies
RUN pip3 install -r requirements.txt --break-system-packages

# Run as root because it's easier
EXPOSE 5000

CMD ["python3", "app.py"]
EOF
echo "  $DOCKER_FILE: Created"

# 4. Build the image
echo "Building image..."
docker build -t $IMAGE_NAME . > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "  Image: $IMAGE_NAME"
    echo "  Build: SUCCESS"
else
    echo "  Build: FAILED"
    exit 1
fi

# 5. Image Analysis
echo "Image Analysis:"
# Get size in MB
IMAGE_SIZE=$(docker images --format "{{.Size}}" $IMAGE_NAME)
echo "  Size: $IMAGE_SIZE"

# Get Base Image (from the first layer/history)
BASE_IMAGE=$(docker history $IMAGE_NAME | grep -o 'ubuntu:latest' | head -1)
echo "  Base: $BASE_IMAGE"

# Check User (Empty string in inspect usually means root/default)
CONTAINER_USER=$(docker inspect --format='{{.Config.User}}' $IMAGE_NAME)
if [ -z "$CONTAINER_USER" ]; then
    echo "  User: root (UID 0)"
else
    echo "  User: $CONTAINER_USER"
fi

# 6. Show exposed environment variables
echo "Environment Variables (EXPOSED SECRETS):"
docker inspect --format='{{range .Config.Env}}{{println .}}{{end}}' $IMAGE_NAME | grep -E "DB_HOST|DB_USER|DB_PASSWORD"

echo "WARNING: This image contains hardcoded credentials!"
