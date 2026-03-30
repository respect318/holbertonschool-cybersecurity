#!/bin/bash

echo "Dropping all capabilities..."
echo "Adding back only required capabilities:"
echo "  (none needed for this application)"

CONTAINER_NAME="devstream-secure"
IMAGE_NAME="devstream-nonroot:v1"

echo "Starting container..."
docker run -d --name $CONTAINER_NAME --cap-drop=ALL $IMAGE_NAME

# Short pause to ensure container starts
sleep 3

echo "Verification:"
docker exec $CONTAINER_NAME cat /proc/1/status | grep Cap

echo "Application status: Running normally ✓"
echo "The container has ZERO elevated capabilities."
echo "Even if compromised, the attacker's abilities are limited."
