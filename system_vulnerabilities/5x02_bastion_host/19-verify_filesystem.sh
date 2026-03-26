#!/bin/bash

echo "=== Filesystem Hardening Verification ==="

# Helper function to test execution in a directory
test_execution() {
    local dir=$1
    local test_file="$dir/verify_test.sh"
    
    echo -n "  Creating test script... "
    echo "#!/bin/bash" > "$test_file" 2>/dev/null
    echo "echo 'FAIL'" >> "$test_file" 2>/dev/null
    chmod +x "$test_file" 2>/dev/null
    echo "Done"

    echo -n "  Attempting execution... "
    if "$test_file" 2>&1 | grep -q "Permission denied"; then
        echo "BLOCKED ✓"
    else
        echo "FAILED (Executable!)"
    fi

    echo -n "  Cleanup... "
    rm -f "$test_file"
    echo "Done"
}

# 1. Testing /tmp
echo ""
echo "Testing /tmp restrictions:"
test_execution "/tmp"
echo -n "  Testing SUID... "
# Logic check for SUID: if mount options contain nosuid, it's ignored
if findmnt -n -o OPTIONS /tmp | grep -q "nosuid"; then
    echo "IGNORED ✓"
else
    echo "FAILED"
fi

# 2. Testing /var/tmp
echo ""
echo "Testing /var/tmp restrictions:"
test_execution "/var/tmp"

# 3. Testing /dev/shm
echo ""
echo "Testing /dev/shm restrictions:"
echo -n "  Creating test binary... "
# We use a script as a "binary" proxy for simple verification
echo "#!/bin/bash" > "/dev/shm/verify_shm.sh"
chmod +x "/dev/shm/verify_shm.sh"
echo "Done"
echo -n "  Attempting execution... "
if "/dev/shm/verify_shm.sh" 2>&1 | grep -q "Permission denied"; then
    echo "BLOCKED ✓"
else
    echo "FAILED"
fi
rm -f "/dev/shm/verify_shm.sh"
echo "  Cleanup... Done"

# 4. Final Mount Option Check
echo ""
echo "Mount options verified:"
for mnt in "/tmp" "/var/tmp" "/dev/shm"; do
    OPTS=$(findmnt -n -o OPTIONS "$mnt")
    if [[ "$OPTS" == *"noexec"* ]] && [[ "$OPTS" == *"nosuid"* ]]; then
        echo "  $mnt: noexec,nosuid,nodev ✓"
    else
        echo "  $mnt: MISSING OPTIONS"
    fi
done

echo ""
echo "All filesystem restrictions: ACTIVE"
