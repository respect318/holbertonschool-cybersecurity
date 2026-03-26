#!/bin/bash

echo "=== Enabling SYN Cookies ==="

CONF_FILE="/etc/sysctl.d/99-hardening.conf"

# Display current state
echo ""
echo "Current state:"
CURRENT_VAL=$(sysctl -n net.ipv4.tcp_syncookies)
echo "  net.ipv4.tcp_syncookies = $CURRENT_VAL"

echo ""
echo "Enabling SYN cookies..."

# Enable SYN cookies immediately
sudo sysctl -w net.ipv4.tcp_syncookies=1 > /dev/null
echo "  net.ipv4.tcp_syncookies = 1"

# Make changes persistent (Append to our hardening config)
{
    echo ""
    echo "# Hardening: SYN Flood Protection"
    echo "net.ipv4.tcp_syncookies = 1"
} | sudo tee -a $CONF_FILE > /dev/null

# Apply settings from the config file
sudo sysctl -p $CONF_FILE > /dev/null

echo ""
echo "Configuration saved to $CONF_FILE"
echo ""
echo "SYN flood protection: ENABLED"
