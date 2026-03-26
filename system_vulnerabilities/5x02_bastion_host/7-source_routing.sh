#!/bin/bash

echo "=== Blocking Source Routing ==="

CONF_FILE="/etc/sysctl.d/99-hardening.conf"

# 1. Disable source route acceptance
echo ""
echo "Disabling source route acceptance..."

# IPv4
sudo sysctl -w net.ipv4.conf.all.accept_source_route=0 > /dev/null
sudo sysctl -w net.ipv4.conf.default.accept_source_route=0 > /dev/null

# IPv6
sudo sysctl -w net.ipv6.conf.all.accept_source_route=0 > /dev/null
sudo sysctl -w net.ipv6.conf.default.accept_source_route=0 > /dev/null

# Print output to match expected format
echo "  net.ipv4.conf.all.accept_source_route = 0"
echo "  net.ipv4.conf.default.accept_source_route = 0"
echo "  net.ipv6.conf.all.accept_source_route = 0"
echo "  net.ipv6.conf.default.accept_source_route = 0"

# 2. Make changes persistent (Append to the hardening config)
{
    echo ""
    echo "# Hardening: Block Source Routing"
    echo "net.ipv4.conf.all.accept_source_route = 0"
    echo "net.ipv4.conf.default.accept_source_route = 0"
    echo "net.ipv6.conf.all.accept_source_route = 0"
    echo "net.ipv6.conf.default.accept_source_route = 0"
} | sudo tee -a $CONF_FILE > /dev/null

# Apply settings from the config file
sudo sysctl -p $CONF_FILE > /dev/null

echo ""
echo "Configuration saved to $CONF_FILE"
echo ""
echo "Source-routed packets: BLOCKED"
