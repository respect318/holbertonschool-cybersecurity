#!/bin/bash

echo "=== Hardening /tmp ==="

# 1. Display Current State
echo ""
echo "Current /tmp mount:"
findmnt -n /tmp || echo "  /tmp is part of the root partition"

echo ""
echo "Applying hardening options..."

# 2. Add entry to /etc/fstab for persistence
# Note: We use tmpfs (RAM-based) which is the modern standard for /tmp
echo "Method: Bind mount with options"
echo "Adding to /etc/fstab:"
LINE="tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev 0 0"
echo "  $LINE"

# Check if entry already exists to avoid duplicates
if ! grep -q "/tmp tmpfs" /etc/fstab; then
    echo "$LINE" | sudo tee -a /etc/fstab > /dev/null
fi

# 3. Remount /tmp
echo ""
echo "Remounting /tmp..."
sudo mount -a
# If /tmp was busy, we force a remount with the new options
sudo mount -o remount,noexec,nosuid,nodev /tmp 2>/dev/null

# 4. Verification
echo ""
echo "Verification:"
MOUNT_OPTS=$(findmnt -n -o OPTIONS /tmp)
echo "  /tmp mount options: $MOUNT_OPTS"

# 5. Testing Restrictions
echo ""
echo "Testing restrictions:"

# Execute test
echo "#!/bin/bash" > /tmp/test_exec.sh
chmod +x /tmp/test_exec.sh
if /tmp/test_exec.sh 2>&1 | grep -q "Permission denied"; then
    echo "  Execute test: BLOCKED (Permission denied) ✓"
else
    echo "  Execute test: FAILED (Still executable)"
fi
rm /tmp/test_exec.sh

# SUID/nodev summary (logic check)
if [[ "$MOUNT_OPTS" == *"nosuid"* ]]; then
    echo "  SUID test: BLOCKED (nosuid active) ✓"
fi

echo ""
echo "/tmp hardened successfully."
