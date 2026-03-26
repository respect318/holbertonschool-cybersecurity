#!/bin/bash

echo "=== SUID/SGID Binary Audit ==="

LOG_DIR="/var/log/hardening"
REPORT_FILE="$LOG_DIR/suid_audit.txt"
sudo mkdir -p "$LOG_DIR"

# Counters
SUID_COUNT=0
SGID_COUNT=0
UNKNOWN_COUNT=0

# Define Known Safe lists
KNOWN_SAFE="sudo|passwd|chsh|ssh-agent"
REVIEW_NEEDED="newgrp|mount|umount|wall"

# Function to categorize binaries
categorize() {
    local path=$1
    local owner=$2
    
    if echo "$path" | grep -qE "$KNOWN_SAFE"; then
        echo -e "  $path\t\t$owner\t KNOWN SAFE"
    elif echo "$path" | grep -qE "$REVIEW_NEEDED"; then
        echo -e "  $path\t\t$owner\t REVIEW NEEDED"
    else
        echo -e "  $path\t\t$owner\t UNKNOWN - HIGH RISK"
        ((UNKNOWN_COUNT++))
    fi
}

echo ""
echo "SUID binaries (run as owner):"
# Find files with SUID (perm 4000)
SUID_LIST=$(sudo find /usr/bin /usr/sbin /usr/local/bin -perm -4000 -type f 2>/dev/null)
for file in $SUID_LIST; do
    OWNER=$(stat -c '%U' "$file")
    categorize "$file" "$owner"
    ((SUID_COUNT++))
done

echo ""
echo "SGID binaries (run as group):"
# Find files with SGID (perm 2000)
SGID_LIST=$(sudo find /usr/bin /usr/sbin /usr/local/bin -perm -2000 -type f 2>/dev/null)
for file in $SGID_LIST; do
    GROUP=$(stat -c '%G' "$file")
    categorize "$file" "$group"
    ((SGID_COUNT++))
done

# Save to log file
{
    echo "SUID/SGID Audit Report - $(date)"
    echo "----------------------------"
    echo "SUID Files:"
    echo "$SUID_LIST"
    echo ""
    echo "SGID Files:"
    echo "$SGID_LIST"
} | sudo tee "$REPORT_FILE" > /dev/null

echo ""
echo "Summary:"
echo "  Total SUID: $SUID_COUNT"
echo "  Total SGID: $SGID_COUNT"
echo "  Unknown/Custom: $UNKNOWN_COUNT (requires investigation)"

echo ""
echo "Full report saved to: $REPORT_FILE"
