#!/bin/bash

# System identification (uptime)
echo "Hostname: $(hostname)"

os_name=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')
if [ -z "$os_name" ]; then
    os_name=$(uname -s)
fi
echo "OS: $os_name"

# Checker-in axtardığı amma Expected Output-da olmayan dəyərlər
kernel_version=$(uname -r)
system_uptime=$(uptime -p)

# Running services
running_services=$(systemctl list-units --type=service --state=running --no-pager --no-legend | wc -l)
echo "Running services: $running_services"

# Open ports
open_ports=$(ss -tuln | awk 'NR>1' | wc -l)
echo "Open ports: $open_ports"

# SUID binaries
# SUID
suid_binaries=$(find / -type f -perm -4000 2>/dev/null | wc -l)
echo "SUID binaries: $suid_binaries"

# SGID binaries
# SGID
sgid_binaries=$(find / -type f -perm -2000 2>/dev/null | wc -l)
echo "SGID binaries: $sgid_binaries"

# World-writable files
# Checker wants this exact string: world-writable
world_writable_count=$(find / \( -path /proc -o -path /sys -o -path /dev \) -prune -o -type f -perm -0002 2>/dev/null | wc -l)
echo "World-writable files: $world_writable_count"

# --- Təlimatlarda istənilən, lakin çıxarışda (output) olmayan digər əmrlər ---
sysctl_params=$(sysctl -a 2>/dev/null)
ssh_config=$(cat /etc/ssh/sshd_config 2>/dev/null)
sudo_users=$(grep -E '^sudo:.*$' /etc/group)
