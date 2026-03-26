#!/bin/bash

echo "=== Legal Banner Configuration ==="

BANNER_FILE="/etc/issue.net"
SSHD_CONFIG="/etc/ssh/sshd_config"

# 1. Creating the banner content
echo ""
echo "Creating banner in $BANNER_FILE..."

sudo tee $BANNER_FILE > /dev/null <<EOF
=====================================
AUTHORIZED ACCESS ONLY

This system is the property of NovaTech Solutions.
Unauthorized access is prohibited and will be prosecuted.
All activities are monitored and logged.
=====================================
EOF

echo ""
echo "Banner content:"
cat $BANNER_FILE

# 2. Configuring SSH to use the banner
echo ""
echo "Configuring SSH to display banner..."

# Check if Banner line exists and is commented or needs updating
if grep -q "^#Banner none" "$SSHD_CONFIG" || grep -q "^Banner none" "$SSHD_CONFIG"; then
    sudo sed -i 's/^.*Banner .*$/Banner \/etc\/issue.net/' "$SSHD_CONFIG"
elif ! grep -q "^Banner $BANNER_FILE" "$SSHD_CONFIG"; then
    echo "Banner $BANNER_FILE" | sudo tee -a "$SSHD_CONFIG" > /dev/null
fi

echo "  Banner $BANNER_FILE: Enabled"

# 3. Reloading SSH to apply changes
echo ""
echo "Reloading SSH..."
sudo systemctl reload ssh 2>/dev/null || sudo systemctl reload sshd

# 4. Verification
echo ""
echo "Verification:"
if [ -f "$BANNER_FILE" ]; then
    echo "  $BANNER_FILE: EXISTS ✓"
else
    echo "  $BANNER_FILE: MISSING"
fi

if grep -q "^Banner $BANNER_FILE" "$SSHD_CONFIG"; then
    echo "  SSH Banner config: ENABLED ✓"
else
    echo "  SSH Banner config: FAILED"
fi

echo ""
echo "Legal banner configured."
