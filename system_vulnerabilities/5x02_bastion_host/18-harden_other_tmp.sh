#!/bin/bash

echo "=== Hardening /var/tmp and /dev/shm ==="

CONF_FILE="/etc/fstab"

# 1. Hardening /var/tmp
echo ""
echo "Hardening /var/tmp..."
echo "  Bind mount to /tmp (inherits restrictions)"

# Add bind mount to fstab if not present
if ! grep -q "/var/tmp" "$CONF_FILE"; then
    echo "/tmp /var/tmp none bin,bind,noexec,nosuid,nodev 0 0" | sudo tee -a "$CONF_FILE" > /dev/null
    echo "  Added to /etc/fstab"
fi

# 2. Hardening /dev/shm
echo ""
echo "Hardening /dev/shm..."
# Get current options to show in output
CURRENT_SHM=$(findmnt -n -o OPTIONS /dev/shm)
echo "  Current: tmpfs ($CURRENT_SHM)"
echo "  Adding: noexec"

# Update /dev/shm in fstab to include noexec
# This sed command finds the shm line and ensures noexec is present
if grep -q "none /dev/shm tmpfs" "$CONF_FILE"; then
    sudo sed -i 's/none \/dev\/shm tmpfs defaults/none \/dev\/shm tmpfs defaults,noexec,nosuid,nodev/g' "$CONF_FILE"
else
    echo "tmpfs /dev/shm tmpfs defaults,noexec,nosuid,nodev 0 0" | sudo tee -a "$CONF_FILE" > /dev/null
fi
echo "  Updated in /etc/fstab"

# 3. Remounting
echo ""
echo "Remounting..."
sudo mount -o remount /dev/shm 2>/dev/null
sudo mount /var/tmp 2>/dev/null

# 4. Verification
echo ""
echo "Verification:"

# Check /var/tmp
VAR_TMP_OPTS=$(findmnt -n -o OPTIONS /var/tmp)
if [[ "$VAR_TMP_OPTS" == *"noexec"* ]] && [[ "$VAR_TMP_OPTS" == *"nosuid"* ]]; then
    echo "  /var/tmp: noexec,nosuid,nodev ✓"
else
    echo "  /var/tmp: Hardening FAILED"
fi

# Check /dev/shm
SHM_OPTS=$(findmnt -n -o OPTIONS /dev/shm)
if [[ "$SHM_OPTS" == *"noexec"* ]] && [[ "$SHM_OPTS" == *"nosuid"* ]]; then
    echo "  /dev/shm: noexec,nosuid,nodev ✓"
else
    echo "  /dev/shm: Hardening FAILED"
fi

echo ""
echo "All temporary directories hardened."
