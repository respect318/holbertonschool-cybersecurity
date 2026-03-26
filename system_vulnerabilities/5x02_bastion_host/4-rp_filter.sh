#!/bin/bash

echo "=== Enabling Reverse Path Filtering ==="

CONF_FILE="/etc/sysctl.d/99-hardening.conf"

echo ""
echo "Setting strict mode (1) for all interfaces..."

# Enable strict mode immediately
sudo sysctl -w net.ipv4.conf.all.rp_filter=1 > /dev/null
sudo sysctl -w net.ipv4.conf.default.rp_filter=1 > /dev/null

echo "  net.ipv4.conf.all.rp_filter = 1"
echo "  net.ipv4.conf.default.rp_filter = 1"

# Make changes persistent (Append mode)
{
    echo ""
    echo "# Hardening: Enable Reverse Path Filtering"
    echo "net.ipv4.conf.all.rp_filter = 1"
    echo "net.ipv4.conf.default.rp_filter = 1"
} | sudo tee -a $CONF_FILE > /dev/null

# Apply settings
sudo sysctl -p $CONF_FILE > /dev/null

echo ""
echo "Configuration saved to $CONF_FILE"
echo ""
echo "Reverse path filtering: STRICT MODE"
echo "Spoofed packets will be dropped."
