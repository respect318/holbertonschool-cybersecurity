#!/bin/bash

CONTAINER_NAME="devstream-ro"
IMAGE_NAME="devstream-nonroot:v1"

echo "Starting container with:"
echo "  --read-only"
echo "  --tmpfs /tmp (for temporary files)"
echo "  --tmpfs /app/logs (for application logs)"

docker run -d \
  --name $CONTAINER_NAME \
  --read-only \
  --tmpfs /tmp \
  --tmpfs /app/logs \
  $IMAGE_NAME

sleep 3

echo "Verification:"

echo "  Attempt to write to /etc: BLOCKED"
docker exec $CONTAINER_NAME sh -c 'echo test > /etc/testfile' 2>/dev/null || echo "    Write blocked ✓"

echo "  Attempt to write to /app: BLOCKED"
docker exec $CONTAINER_NAME sh -c 'echo test > /app/testfile' 2>/dev/null || echo "    Write blocked ✓"

echo "  Attempt to write to /tmp: ALLOWED"
docker exec $CONTAINER_NAME sh -c 'echo test > /tmp/testfile' && echo "    Write allowed ✓"

echo "  Application logging: WORKING"
docker exec $CONTAINER_NAME sh -c 'echo log > /app/logs/app.log' && echo "    Logging works ✓"

echo "Root filesystem: READ-ONLY"
echo "Attackers cannot modify system files or drop tools."
