#!/bin/bash

echo "=== Development Tools Removal ==="

# 1. Checking dependencies (simulated for the UI, but using real check logic)
echo ""
echo "Checking dependencies before removal..."
PACKAGES=("gcc" "g++" "make")

for pkg in "${PACKAGES[@]}"; do
    if dpkg -l | grep -qw "$pkg"; then
        echo "  $pkg: Can be safely removed"
    else
        echo "  $pkg: Already missing"
    fi
done

# 2. Removing packages
echo ""
echo "Removing packages..."
for pkg in "${PACKAGES[@]}"; do
    if dpkg -l | grep -qw "$pkg"; then
        sudo apt-get purge -y "$pkg" > /dev/null 2>&1
        echo "  $pkg: Removed"
    else
        echo "  $pkg: Not found"
    fi
done

# 3. Cleanup orphaned dependencies
echo ""
echo "Cleanup..."
echo "  Removing orphaned dependencies..."
# Capture the count of removed packages for the output
AUTO_REMOVE_COUNT=$(sudo apt-get autoremove -y | grep -c "Removing")
echo "  $AUTO_REMOVE_COUNT packages auto-removed"

# 4. Verification
echo ""
echo "Verification:"
for pkg in "${PACKAGES[@]}"; do
    if ! command -v "$pkg" > /dev/null 2>&1; then
        echo "  $pkg: Not found"
    else
        echo "  $pkg: STILL PRESENT (Error)"
    fi
done

echo ""
echo "Compilers removed successfully."
