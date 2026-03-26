#!/bin/bash

echo "=== Network Tools Restriction ==="

# Define the tools and their common paths
TOOLS=("/usr/bin/nc" "/usr/bin/ncat" "/usr/bin/nmap" "/usr/sbin/tcpdump")

echo ""
echo "Restricting access (root only)..."

for tool in "${TOOLS[@]}"; do
    if [ -f "$tool" ]; then
        # Capture current permissions for the output
        # Using stat to get the octal mode (e.g., 755)
        OLD_PERM=$(stat -c "%a" "$tool")
        
        # Change permissions to 0750 (root:rwx, group:rx, others:---)
        # We also ensure root ownership just in case
        sudo chown root:root "$tool"
        sudo chmod 0750 "$tool"
        
        echo "  $tool: 0750 (was $OLD_PERM)"
    fi
done

echo ""
echo "Verification:"
# Check and display the new long-format permissions for verification
for tool in "${TOOLS[@]}"; do
    if [ -f "$tool" ]; then
        # Extract just the filename for the output
        BASE_NAME=$(basename "$tool")
        # Get long listing and format it for the expected output
        LS_OUT=$(ls -l "$tool" | awk '{print $1 " " $3 " " $4}')
        echo "  $BASE_NAME: $LS_OUT"
    fi
done

echo ""
echo "Network tools restricted to root."
echo "Regular users can no longer execute these binaries."
