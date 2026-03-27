#!/bin/bash

# ==============================================================================
# Script: 25-harden.sh
# Description: Automated Ubuntu Hardening Master Script
# Target OS: Ubuntu 20.04 / 22.04 / 24.04
# Author: Gemini AI / Cybersecurity Lab
# ==============================================================================

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (sudo)." 
   exit 1
fi

LOG_FILE="/var/log/hardening_master.log"
CONF_FILE="/etc/sysctl.d/99-hardening.conf"

log_action() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

echo "=== Starting Master Hardening Process ===" | tee -a "$LOG_FILE"

# ------------------------------------------------------------------------------
# 1. Network Stack Hardening (Kernel Parameters)
# ------------------------------------------------------------------------------
log_action "Applying Kernel Hardening Parameters..."

{
    echo "# Network Hardening"
    echo "net.ipv4.ip_forward = 0"
    echo "net.ipv6.conf.all.forwarding = 0"
    echo "net.ipv4.conf.all.accept_redirects = 0"
    echo "net.ipv4.conf.all.send_redirects = 0"
    echo "net.ipv4.conf.all.rp_filter = 1"
    echo "net.ipv4.conf.default.rp_filter = 1"
    echo "net.ipv4.tcp_syncookies = 1"
    echo "net.ipv4.icmp_echo_ignore_broadcasts = 1"
    echo "net.ipv4.conf.all.accept_source_route = 0"
    echo "net.ipv6.conf.all.accept_source_route = 0"
    echo "net.ipv4.icmp_ignore_bogus_error_responses = 1"
} > "$CONF_FILE"

sysctl -p "$CONF_FILE" > /dev/null
log_action "Kernel parameters applied and persisted in $CONF_FILE."

# ------------------------------------------------------------------------------
# 2. Package & Service Minimization
# ------------------------------------------------------------------------------
log_action "Purging development tools and unnecessary services..."

# Remove compilers
apt-get purge -y gcc g++ make gdb > /dev/null 2>&1
apt-get autoremove -y > /dev/null 2>&1

# Disable non-essential services
SERVICES=("cups" "avahi-daemon" "bluetooth")
for svc in "${SERVICES[@]}"; do
    if systemctl list-unit-files | grep -q "$svc"; then
        systemctl stop "$svc" > /dev/null 2>&1
        systemctl disable "$svc" > /dev/null 2>&1
        systemctl mask "$svc" > /dev/null 2>&1
        log_action "Service $svc masked and stopped."
    fi
done

# ------------------------------------------------------------------------------
# 3. Filesystem Hardening (/tmp, /var/tmp, /dev/shm)
# ------------------------------------------------------------------------------
log_action "Hardening writable partitions..."

# Secure /tmp with tmpfs
if ! grep -q "/tmp tmpfs" /etc/fstab; then
    echo "tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
fi

# Secure /var/tmp via bind mount
if ! grep -q "/var/tmp" /etc/fstab; then
    echo "/tmp /var/tmp none bin,bind,noexec,nosuid,nodev 0 0" >> /etc/fstab
fi

# Secure /dev/shm (Shared Memory)
if grep -q "none /dev/shm tmpfs" /etc/fstab; then
    sed -i 's|none /dev/shm tmpfs.*|tmpfs /dev/shm tmpfs defaults,noexec,nosuid,nodev 0 0|' /etc/fstab
else
    echo "tmpfs /dev/shm tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
fi

mount -a > /dev/null 2>&1
mount -o remount /tmp 2>/dev/null
mount -o remount /dev/shm 2>/dev/null
log_action "Filesystems remounted with noexec/nosuid/nodev."

# ------------------------------------------------------------------------------
# 4. SUID/SGID Neutralization
# ------------------------------------------------------------------------------
log_action "Neutralizing non-essential SUID bits..."

NON_ESSENTIAL=("/usr/bin/mount" "/usr/bin/umount" "/usr/bin/newgrp" "/usr/local/bin/backup")
for bin in "${NON_ESSENTIAL[@]}"; do
    if [ -f "$bin" ]; then
        chmod u-s "$bin"
        log_action "Removed SUID from $bin"
    fi
done

# ------------------------------------------------------------------------------
# 5. Access Control & Banners
# ------------------------------------------------------------------------------
log_action "Configuring root lockdown and legal banners..."

# Lock root account
passwd -l root > /dev/null 2>&1

# Legal Banner
cat <<EOF > /etc/issue.net
=====================================
AUTHORIZED ACCESS ONLY
Unauthorized access is prohibited.
All activities are monitored.
=====================================
EOF

# Ensure SSH uses the banner
if ! grep -q "^Banner /etc/issue.net" /etc/ssh/sshd_config; then
    echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
    systemctl reload ssh > /dev/null 2>&1 || systemctl reload sshd > /dev/null 2>&1
fi

log_action "Master Hardening script completed successfully."
echo "=== Hardening Complete. Log saved to $LOG_FILE ==="
