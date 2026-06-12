#!/bin/bash

# Check that 9-rollback.sh handles a single package argument and validates missing argument
if [ -z "$1" ]; then
    echo "Usage: $0 <package>"
    exit 1
fi

PACKAGE="$1"

# Get current version before rollback
CURRENT_VERSION=$(dpkg-query -W -f='${Version}' "$PACKAGE" 2>/dev/null || echo "unknown")

# Load the target version from pre_patch_state.json
TARGET_VERSION=$(jq -r ".packages[\"$PACKAGE\"]" pre_patch_state.json 2>/dev/null)

# Fail clearly when the package is not found in the snapshot
if [ "$TARGET_VERSION" == "null" ] || [ -z "$TARGET_VERSION" ]; then
    echo "Error: Package $PACKAGE missing from snapshot."
    exit 1
fi

echo "[*] Target version from pre_patch_state.json: $TARGET_VERSION"

# Check target version availability
if ! apt-cache madison "$PACKAGE" | grep -q "$TARGET_VERSION"; then
    echo "Error: Version not available."
    exit 1
fi

echo "[*] Version available in cache or repository: yes"

# Perform a noninteractive apt downgrade
echo -n "[*] Downgrading $PACKAGE...                              "
if DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-downgrades "$PACKAGE=$TARGET_VERSION" >/dev/null 2>&1; then
    echo "OK"
else
    echo "FAIL"
    exit 1
fi

# Pin the downgraded package with apt-mark hold
echo -n "[*] apt-mark hold $PACKAGE                               "
if apt-mark hold "$PACKAGE" >/dev/null 2>&1; then
    echo "OK"
else
    echo "FAIL"
    exit 1
fi

# Read service_dependency_map.json for affected services and run probes
echo "[*] Re-running probes for affected services..."
AFFECTED_SERVICES=$(jq -r --arg pkg "$PACKAGE" 'to_entries[] | select(.value.linked_packages != null) | select(.value.linked_packages[] == $pkg) | .key' service_dependency_map.json 2>/dev/null)

for service in $AFFECTED_SERVICES; do
    echo -n "    $service probe                                  "
    # Using systemctl as a lightweight probe check
    if systemctl is-active --quiet "$service"; then
        echo "PASS"
    else
        echo "FAIL"
        exit 1
    fi
done

# Print rollback status and version summary
echo "ROLLBACK: success"
echo "from $CURRENT_VERSION to $TARGET_VERSION"

exit 0
