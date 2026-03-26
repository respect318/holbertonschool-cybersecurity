#!/bin/bash

echo "=== Living off the Land Binaries Audit ==="

# Function to check binary and output status based on risk
check_bin() {
    local path=$1
    local risk_msg=$2
    
    if [ -f "$path" ]; then
        # Get permissions in long format
        PERMS=$(ls -l "$path" | awk '{print $1}')
        
        # If the risk_msg is "OK", just print OK, otherwise print the warning
        if [ "$risk_msg" == "OK" ]; then
            echo "  $path: $PERMS (OK)"
        else
            echo "  $path: $PERMS (WARNING: $risk_msg)"
        fi
    fi
}

echo ""
echo "Checking GTFOBins candidates..."

echo ""
echo "File Readers (can read sensitive files):"
check_bin "/usr/bin/cat" "OK"
check_bin "/usr/bin/less" "OK"
check_bin "/usr/bin/vim" "Can escape to shell"

echo ""
echo "Shell Escapes:"
check_bin "/usr/bin/python3" "Can spawn shells"
check_bin "/usr/bin/perl" "Can spawn shells"
check_bin "/usr/bin/awk" "OK"

echo ""
echo "Network Tools:"
check_bin "/usr/bin/wget" "Can download payloads"
check_bin "/usr/bin/curl" "Can download payloads"

echo ""
echo "Note: These binaries are legitimate but should be monitored."
echo "See https://gtfobins.github.io/ for abuse techniques."
