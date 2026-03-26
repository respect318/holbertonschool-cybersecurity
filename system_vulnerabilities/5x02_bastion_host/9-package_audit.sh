#!/bin/bash

echo "=== Package Security Audit ==="

# Counters for the summary
DEV_COUNT=0
NET_COUNT=0
REMOTE_COUNT=0

# Helper function to check if a package is installed
check_pkg() {
    local pkg_name=$1
    local description=$2
    local category=$3

    if dpkg -l | grep -qw "$pkg_name"; then
        echo "  [FOUND] $pkg_name ($description)"
        case $category in
            "dev") ((DEV_COUNT++)) ;;
            "net") ((NET_COUNT++)) ;;
            "remote") ((REMOTE_COUNT++)) ;;
        esac
    fi
}

echo ""
echo "Checking for development tools..."
check_pkg "gcc" "GNU C Compiler" "dev"
check_pkg "g++" "GNU C++ Compiler" "dev"
check_pkg "make" "Build automation" "dev"
check_pkg "gdb" "Debugger" "dev"

echo ""
echo "Checking for network tools..."
check_pkg "netcat-openbsd" "Network Swiss Army Knife" "net"
# Also checking common alternative name for netcat
check_pkg "nc-traditional" "Network Swiss Army Knife" "net"
check_pkg "nmap" "Network scanner" "net"
check_pkg "tcpdump" "Packet capture" "net"

echo ""
echo "Checking for remote access tools..."
check_pkg "telnet" "Insecure remote access" "remote"

echo ""
echo "Summary:"
echo "  Development tools: $DEV_COUNT found"
echo "  Network tools: $NET_COUNT found"
echo "  Remote access: $REMOTE_COUNT found"

echo ""
echo "Recommendation: Review and remove unnecessary packages."
