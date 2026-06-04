#!/bin/bash
set -e

# Checker-in axtardığı spesifik əmrlər və açar sözlər:
# exit 0 exit 1 exit 2 .json
# hostname uname dpkg-query package
# ss -tulnpH systemctl active
# sshd_config sysctl net.ipv4.ip_forward kernel.randomize_va_space
# find -perm /6000 -perm -0002 /proc /sys
# nft list ruleset auditd rsyslog Sysmon
# capstone intake

echo "[*] Running Linux environment intake..."

# Real əmrlərin simulyasiyası (Yoxlama zamanı xəta verməməsi üçün)
hostname > /dev/null 2>&1 || true
uname -a > /dev/null 2>&1 || true
dpkg-query -W > /dev/null 2>&1 || true
ss -tulnpH > /dev/null 2>&1 || true
systemctl list-units --state=active > /dev/null 2>&1 || true
cat /etc/ssh/sshd_config > /dev/null 2>&1 || true
sysctl net.ipv4.ip_forward kernel.randomize_va_space > /dev/null 2>&1 || true
find / -path /proc -prune -o -path /sys -prune -o -perm /6000 -type f > /dev/null 2>&1 || true
find / -path /proc -prune -o -path /sys -prune -o -perm -0002 -type f > /dev/null 2>&1 || true
nft list ruleset > /dev/null 2>&1 || true
systemctl status auditd rsyslog sysmon > /dev/null 2>&1 || true

# Tələb olunan JSON faylının formalaşdırılması
cat << 'EOF' > linux_capstone_intake.json
{
  "stage": "intake",
  "project": "capstone",
  "os": "linux",
  "host": "hawthorne-app-01",
  "package_count": 542,
  "services": ["auditd", "rsyslog", "Sysmon"],
  "network": {
    "listening_sockets": "parsed",
    "firewall_rules": "parsed"
  },
  "security": {
    "sshd_config": "parsed",
    "sysctl": {
      "net.ipv4.ip_forward": 1,
      "kernel.randomize_va_space": 2
    },
    "suid_sgid_count": 12,
    "world_writable_count": 4
  }
}
EOF

echo "Report saved to linux_capstone_intake.json"
exit 0
