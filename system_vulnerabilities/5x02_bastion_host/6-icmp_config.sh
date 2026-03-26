#!/bin/bash

echo "=== ICMP Configuration ==="

CONF_FILE="/etc/sysctl.d/99-hardening.conf"

# 1. Disable broadcast ping response (Smurf prevention)
echo ""
echo "Disabling broadcast ping response (Smurf prevention)..."
sudo sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1 > /dev/null
echo "  net.ipv4.icmp_echo_ignore_broadcasts = 1"

# 2. Keep unicast ping enabled for diagnostics
echo ""
echo "Keeping unicast ping enabled for diagnostics."
sudo sysctl -w net.ipv4.icmp_echo_ignore_all=0 > /dev/null
echo "  net.ipv4.icmp_echo_ignore_all = 0"

# 3. Ignore bogus ICMP error responses
echo ""
echo "Ignoring bogus ICMP error responses..."
sudo sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1 > /dev/null
echo "  net.ipv4.icmp_ignore_bogus_error_responses = 1"

# 4. Make changes persistent
{
    echo ""
    echo "# Hardening: ICMP Configuration"
    echo "net.ipv4.icmp_echo_ignore_broadcasts = 1"
    echo "net.ipv4.icmp_echo_ignore_all = 0"
    echo "net.ipv4.icmp_ignore_bogus_error_responses = 1"
} | sudo tee -a $CONF_FILE > /dev/null

# Apply settings
sudo sysctl -p $CONF_FILE > /dev/null

echo ""
echo "Configuration saved to $CONF_FILE"
echo ""
echo "Broadcast ping: DISABLED"
echo "Unicast ping: ENABLED"
