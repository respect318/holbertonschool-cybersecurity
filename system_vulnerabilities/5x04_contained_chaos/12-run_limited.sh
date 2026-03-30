#!/bin/bash

CONTAINER_NAME="devstream-limited"
IMAGE_NAME="devstream-nonroot:v1"

echo "Applying limits:"
echo "  --memory=256m (max 256MB RAM)"
echo "  --memory-swap=256m (no swap)"
echo "  --cpus=0.5 (max 50% of one CPU)"
echo "  --pids-limit=50 (max 50 processes)"

docker run -d \
  --name $CONTAINER_NAME \
  --memory=256m \
  --memory-swap=256m \
  --cpus=0.5 \
  --pids-limit=50 \
  $IMAGE_NAME

sleep 3

echo "Container started: $CONTAINER_NAME"
echo "Verification:"

MEM_LIMIT=$(docker inspect $CONTAINER_NAME --format='{{.HostConfig.Memory}}')
CPU_LIMIT=$(docker inspect $CONTAINER_NAME --format='{{.HostConfig.NanoCpus}}')
PIDS_LIMIT=$(docker inspect $CONTAINER_NAME --format='{{.HostConfig.PidsLimit}}')

echo "  Memory limit: $((MEM_LIMIT/1024/1024))MB"
echo "  CPU limit: $(echo "$CPU_LIMIT / 1000000000" | bc -l) cores"
echo "  PID limit: $PIDS_LIMIT"

echo "Resource limits active."
echo "Container cannot exhaust host resources."
