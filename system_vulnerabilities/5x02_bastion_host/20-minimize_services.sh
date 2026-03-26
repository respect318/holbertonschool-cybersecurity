#!/bin/bash

echo "=== Service Minimization ==="

# Define lists for the audit
UNNECESSARY=("cups.service" "avahi-daemon.service" "bluetooth.service")
ESSENTIAL=("ssh.service" "apache2.service")

echo ""
echo "Checking for unnecessary services..."
echo ""
echo "Unnecessary services found:"

# Check for unnecessary services and describe why they are being targeted
for svc in "${UNNECESSARY[@]}"; do
    case "$svc" in
        "cups.service") DESC="(Printing) - Not needed on web server" ;;
        "avahi-daemon.service") DESC="(mDNS) - Not needed on web server" ;;
        "bluetooth.service") DESC="(Bluetooth) - Not needed on server" ;;
    esac
    
    # Check if the service exists/is installed
    if systemctl list-unit-files | grep -q "$svc"; then
        echo "  $svc $DESC"
    fi
done

echo ""
echo "Disabling services..."

# Stop and disable the services
for svc in "${UNNECESSARY[@]}"; do
    if systemctl list-unit-files | grep -q "$svc"; then
        # Stop the service and disable it from starting at boot
        sudo systemctl stop "$svc" > /dev/null 2>&1
        sudo systemctl disable "$svc" > /dev/null 2>&1
        # Masking prevents other services from accidentally starting it
        sudo systemctl mask "$svc" > /dev/null 2>&1
        echo "  $svc: Disabled and stopped"
    fi
done

echo ""
echo "Essential services preserved:"

# Verify essential services are still active
for svc in "${ESSENTIAL[@]}"; do
    # Note: ssh service name varies (ssh vs sshd), checking both
    if systemctl is-active --quiet "$svc" || systemctl is-active --quiet "sshd.service"; then
        # Format the name for the output
        DISPLAY_NAME=$svc
        [[ "$svc" == "ssh.service" ]] && DISPLAY_NAME="sshd.service"
        echo "  $DISPLAY_NAME: Running ✓"
    else
        # If it's not running, we report it (useful for debugging your lab)
        echo "  $svc: NOT RUNNING (Warning)"
    fi
done

echo ""
echo "Services reduced. Attack surface minimized."
