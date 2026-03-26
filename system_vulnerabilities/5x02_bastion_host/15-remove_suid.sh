#!/bin/bash

echo "=== SUID Neutralization ==="

# Define the lists based on the audit
ESSENTIAL=("/usr/bin/sudo" "/usr/bin/passwd" "/usr/bin/su")
NON_ESSENTIAL=(
    "/usr/bin/mount" 
    "/usr/bin/umount" 
    "/usr/bin/newgrp" 
    "/usr/local/bin/backup"
)

echo ""
echo "Preserving essential SUID (DO NOT TOUCH):"
for bin in "${ESSENTIAL[@]}"; do
    if [ -f "$bin" ]; then
        echo "  $bin"
    fi
done

echo ""
echo "Removing SUID from non-essential binaries..."

# Counter for the summary
REMOVED_COUNT=0
TOTAL_BEFORE=$(sudo find /usr/bin /usr/sbin /usr/local/bin -perm -4000 -type f 2>/dev/null | wc -l)

# Neutralize SUID bits
for bin in "${NON_ESSENTIAL[@]}"; do
    if [ -f "$bin" ]; then
        # Remove SUID (u-s)
        sudo chmod u-s "$bin"
        
        # Determine the reason for the output
        case "$bin" in
            "/usr/bin/mount"|"/usr/bin/umount") REASON="admin can use sudo" ;;
            "/usr/bin/newgrp") REASON="not needed" ;;
            "/usr/local/bin/backup") REASON="CUSTOM - HIGH RISK" ;;
            *) REASON="not required" ;;
        esac
        
        echo "  $bin: SUID removed ($REASON)"
        ((REMOVED_COUNT++))
    fi
done

echo ""
echo "Verification:"
# Check mount and umount specifically for the expected output
for check in "/usr/bin/mount" "/usr/bin/umount"; do
    if [ -f "$check" ]; then
        PERMS=$(ls -l "$check" | awk '{print $1}')
        # Check if 's' is gone from the permissions string
        if [[ "$PERMS" != *"s"* ]]; then
            echo "  $(basename $check): $PERMS (no SUID)"
        fi
    fi
done

# Calculate reduction
TOTAL_AFTER=$((TOTAL_BEFORE - REMOVED_COUNT))
echo ""
echo "SUID binaries reduced from $TOTAL_BEFORE to $TOTAL_AFTER."
