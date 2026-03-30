#!/bin/bash

IMAGE="$1"

if [ -z "$IMAGE" ]; then
    echo "Usage: $0 <image>"
    exit 1
fi

echo "Image: $IMAGE"
echo "Layer History:"

# Get history without truncation
HISTORY=$(docker history --no-trunc "$IMAGE")

# Print layers with numbering
i=1
echo "$HISTORY" | tail -n +2 | while read -r line; do
    CMD=$(echo "$line" | awk '{$1=$2=$3=$4=$5=""; print $0}' | sed 's/^ *//')

    OUTPUT="  Layer $i: $CMD"

    # Highlight secrets
    if echo "$CMD" | grep -q "chpasswd"; then
        OUTPUT="$OUTPUT  ← PASSWORD EXPOSED"
    fi

    if echo "$CMD" | grep -q "DB_PASSWORD"; then
        OUTPUT="$OUTPUT  ← SECRET EXPOSED"
    fi

    echo "$OUTPUT"
    i=$((i+1))
done

echo "Extracting secrets from history..."

# Extract root password
ROOT_PASS=$(echo "$HISTORY" | grep "chpasswd" | sed -n "s/.*root:\([^']*\).*/\1/p")

# Extract DB password
DB_PASS=$(echo "$HISTORY" | grep "DB_PASSWORD" | sed -n "s/.*DB_PASSWORD=\([^ ]*\).*/\1/p")

echo "  Root password: $ROOT_PASS"
echo "  DB Password: $DB_PASS"

echo "CRITICAL: All ENV and RUN commands are permanently"
echo "visible in image layers. Never put secrets here!"
