#!/bin/bash

echo "Running docker-bench-security..."

# Clone if not exists
if [ ! -d "docker-bench-security" ]; then
    git clone https://github.com/docker/docker-bench-security.git
fi

cd docker-bench-security || exit 1

# Run benchmark and save output
OUTPUT=$(sudo sh docker-bench-security.sh)

# Print relevant lines (WARN / PASS / INFO / NOTE)
echo "$OUTPUT" | grep -E "\[WARN\]|\[PASS\]|Container Runtime Checks"

echo "Summary:"

PASS_COUNT=$(echo "$OUTPUT" | grep -c "\[PASS\]")
WARN_COUNT=$(echo "$OUTPUT" | grep -c "\[WARN\]")
INFO_COUNT=$(echo "$OUTPUT" | grep -c "\[INFO\]")
NOTE_COUNT=$(echo "$OUTPUT" | grep -c "\[NOTE\]")

echo "  PASS: $PASS_COUNT"
echo "  WARN: $WARN_COUNT"
echo "  INFO: $INFO_COUNT"
echo "  NOTE: $NOTE_COUNT"

# Simple score calculation
TOTAL=$((PASS_COUNT + WARN_COUNT + INFO_COUNT + NOTE_COUNT))

if [ "$TOTAL" -gt 0 ]; then
    SCORE=$((PASS_COUNT * 100 / TOTAL))
else
    SCORE=0
fi

echo "Score: $SCORE% (CRITICAL - Do not deploy)"
