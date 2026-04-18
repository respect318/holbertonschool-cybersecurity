#!/bin/bash

echo "Hostname: $(hostname)"

echo "OS: $(grep '^PRETTY_NAME' /etc/os-release | cut -d= -f2 | tr -d '\"')"

echo "Kernel: $(uname -r)"

echo "Uptime: $(uptime -p)"

echo "Running services: $(systemctl list-units --type=service --state=running --no-legend | wc -l)"

echo "Open ports: $(ss -tuln | awk 'NR>1' | wc -l)"

echo "SUID binaries: $(find / -perm -4000 -type f 2>/dev/null | wc -l)"

echo "SGID binaries: $(find / -perm -2000 -type f 2>/dev/null | wc -l)"

echo "World-writable files: $(find / \( -path /proc -o -path /sys -o -path /dev \) -prune -false -o -type f -perm -0002 2>/dev/null | wc -l)"

echo "Sysctl security parameters:"
sysctl -a 2>/dev/null | grep -E 'kernel|net.ipv4|fs.protected' | head -n 10

echo "SSH security settings:"
grep -E '^(PermitRootLogin|PasswordAuthentication|PubkeyAuthentication)' /etc/ssh/sshd_config 2>/dev/null

echo "Active users: $(cut -d: -f1 /etc/passwd | wc -l)"

echo "Sudo group members:"
getent group sudo | cut -d: -f4
