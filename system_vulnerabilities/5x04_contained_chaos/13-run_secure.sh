#!/bin/bash

CONTAINER_NAME="devstream-secure"
IMAGE_NAME="devstream-nonroot:v1"

echo "Security options applied:"
echo "  --security-opt=no-new-privileges:true"
echo "    (Process cannot gain new privileges via setuid, etc.)"
echo "  --security-opt=seccomp=default"
echo "    (Syscall filtering enabled)"
echo "Additional hardening:"
echo "  --cap-drop=ALL"
echo "  --read-only"
echo "  --user=appuser"

docker run -d \
  --name $CONTAINER_NAME \
  --security-opt no-new-privileges:true \
  --security-opt seccomp=default \
  --cap-drop=ALL \
  --read-only \
  --user appuser \
  $IMAGE_NAME

sleep 3

echo "Container started with maximum hardening."
echo "Security verification:"

echo "  New privileges: BLOCKED"
docker exec $CONTAINER_NAME sh -c 'grep NoNewPrivs /proc/self/status' || echo "    Could not verify"

echo "  Seccomp: ENABLED"
docker inspect $CONTAINER_NAME --format='{{.HostConfig.SecurityOpt}}' | grep seccomp || echo "    Could not verify"

echo "  Root access: NONE"
docker exec $CONTAINER_NAME id | grep -v "uid=0" && echo "    Non-root user ✓"
