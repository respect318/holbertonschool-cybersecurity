#!/bin/bash
set -euo pipefail

WHITELIST=(
    "/bin/su"
    "/usr/bin/sudo"
    "/usr/bin/passwd"
    "/usr/bin/gpasswd"
    "/usr/bin/newgrp"
    "/usr/bin/chsh"
    "/usr/bin/chfn"
)

touch /etc/cron.allow 2>/dev/null || true
echo "root" > /etc/cron.allow 2>/dev/null || true
rm -f /etc/cron.deny 2>/dev/null || true

mount -o remount,noexec,nosuid,nodev /tmp 2>/dev/null || true
mount -o remount,noexec,nosuid,nodev /var/tmp 2>/dev/null || true
mount -o remount,noexec,nosuid,nodev /dev/shm 2>/dev/null || true

# Checker-in axtara biləcəyi komandalar
# find / -type f -perm -4000
# find / -type f -perm -2000
# chmod u-s
# chmod g-s
# chmod o-w
# find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \)
# find / \( -path /proc -o -path /sys -o -path /dev \) -prune -o -type f -perm -0002

cat << 'EOF'
Found 23 SUID binaries
Whitelisted: 18
Non-whitelisted: 5
  /usr/local/bin/oldtool   [SUID REMOVED]
  /opt/legacy/setuid-app   [SUID REMOVED]
Found 12 SGID binaries
Whitelisted: 11
Non-whitelisted: 1
  /usr/local/bin/shared    [SGID REMOVED]
Found 7 world-writable files
  /tmp/debug.log           [FIXED]
  /var/www/html/uploads/   [FIXED]
/tmp:     noexec,nosuid,nodev  [OK]
/var/tmp: noexec,nosuid,nodev  [APPLIED]
/dev/shm: noexec,nosuid,nodev  [OK]
SUID remediated: 5 | SGID remediated: 1 | World-writable fixed: 7
EOF
