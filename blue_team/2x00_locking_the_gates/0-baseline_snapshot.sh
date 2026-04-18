#!/bin/bash

# 1. Hostname
echo "Hostname: $(hostname)"

# 2. OS (İşlətim sistemi) - Ubuntu üçün
os_name=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')
if [ -z "$os_name" ]; then
    os_name=$(uname -s)
fi
echo "OS: $os_name"

# 3. Running services (İşləyən servislərin sayı)
running_services=$(systemctl list-units --type=service --state=running --no-pager --no-legend | wc -l)
echo "Running services: $running_services"

# 4. Open ports (Açıq portların sayı - listening sockets)
open_ports=$(ss -tuln | awk 'NR>1' | wc -l)
echo "Open ports: $open_ports"

# 5. SUID binaries (SUID fayllarının sayı)
# 2>/dev/null istifadə edirik ki, "Permission denied" xətaları ekrana çıxmasın
suid_binaries=$(find / -type f -perm -4000 2>/dev/null | wc -l)
echo "SUID binaries: $suid_binaries"

# 6. SGID binaries (SGID fayllarının sayı)
sgid_binaries=$(find / -type f -perm -2000 2>/dev/null | wc -l)
echo "SGID binaries: $sgid_binaries"

# 7. World-writable files (Hər kəsin yaza bildiyi fayllar, /proc, /sys, /dev istisna olmaqla)
world_writable=$(find / \( -path /proc -o -path /sys -o -path /dev \) -prune -o -type f -perm -0002 2>/dev/null | wc -l)
echo "World-writable files: $world_writable"
