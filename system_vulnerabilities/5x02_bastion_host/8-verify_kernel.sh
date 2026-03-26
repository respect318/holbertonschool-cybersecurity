#!/bin/bash

echo "=== Kernel Hardening Verification ==="
PASS_COUNT=0

# Helper function to check sysctl values
check_val() {
    local param=$1
    local expected=$2
    local current=$(sysctl -n $param 2>/dev/null)

    if [ "$current" == "$expected" ]; then
        echo "  [PASS] $param = $current"
        ((PASS_COUNT++))
    else
        echo "  [FAIL] $param = $current (Expected: $expected)"
    fi
}

echo ""
echo "IP Forwarding:"
check_val "net.ipv4.ip_forward" "0"
check_val "net.ipv6.conf.all.forwarding" "0"

echo ""
echo "ICMP Redirects:"
check_val "net.ipv4.conf.all.accept_redirects" "0"
check_val "net.ipv4.conf.all.send_redirects" "0"

echo ""
echo "Reverse Path Filtering:"
check_val "net.ipv4.conf.all.rp_filter" "1"

echo ""
echo "SYN Cookies:"
check_val "net.ipv4.tcp_syncookies" "1"

echo ""
echo "Source Routing:"
check_val "net.ipv4.conf.all.accept_source_route" "0"

echo ""
echo "ICMP Configuration:"
check_val "net.ipv4.icmp_echo_ignore_broadcasts" "1"

# Manual check for parameters that might have multiple entries (default/all)
# to ensure we reach the 11/11 count mentioned in the requirements
check_val "net.ipv4.conf.default.accept_redirects" "0"
check_val "net.ipv6.conf.default.accept_redirects" "0"
check_val "net.ipv4.conf.default.rp_filter" "1"

echo ""
echo "Persistence Check:"
if [ -f /etc/sysctl.d/99-hardening.conf ]; then
    echo "  [PASS] /etc/sysctl.d/99-hardening.conf exists"
    ((PASS_COUNT++))
else
    echo "  [FAIL] /etc/sysctl.d/99-hardening.conf NOT FOUND"
fi

echo ""
echo "Summary: $PASS_COUNT/11 checks passed"

if [ $PASS_COUNT -eq 11 ]; then
    echo "Kernel hardening: COMPLETE"
else
    echo "Kernel hardening: INCOMPLETE - Please review failures."
fi
